#!/usr/bin/env -S docker build --compress -t pvtmert/healer -f

FROM debian:stable

RUN apt update
RUN apt install -y curl jq

SHELL [ "/bin/bash", "-c" ]
ENV MAIN   entrypoint.sh
ENV QUERY  docker.jq
ENV HEALTH health.sh
ENV SOCKET /var/run/docker.sock
ENV THREADS ""
ENV INTERVAL 5.0
ENV HEAL_STATE "unhealthy"
ENV HEAL_LABEL "ext.heal.me"
ENV HEAL_VALUE "true"

RUN echo $'#!/usr/bin/env bash\n\
: ${1:? missing filename}\n\
test -e "$1" || exit\n\
TIME="$(date +%s)"\n\
LAST="$(stat -c %Y "$1")"\n\
test "${INTERVAL%.*}" -ge "$(( (TIME - LAST) / 3 ))"\n\
exit $?\n' | tee "${HEALTH}"

RUN echo $'#!/usr/bin/env jq\n\
#!/usr/bin/env jq -f\n\
.[] | select(true\n\
	and ( ($_state | length == 0) or (.Status | contains($_state)) )\n\
	and ( ($_label | length == 0) or (.Labels | has($_label))      )\n\
	and ( ($_value | length == 0) or (true\n\
		and ($_value | length > 0)\n\
		and ($_label | length > 0)\n\
		and (.Labels[$_label] | contains($_value))\n\
	) )\n\
) | .Id\n' | tee "${QUERY}"

RUN echo $'#!/usr/bin/env bash\n\
function call {\n\
	curl -sfX "${1}" --unix-socket "${SOCKET}" "http://host${@:2}"\n\
}\n\
export -f call\n\
while sleep ${INTERVAL:-1.0}; do\n\
	call GET /containers/json \\\n\
	| jq -Crf "${QUERY}" \\\n\
		--arg _state "${HEAL_STATE}" \\\n\
		--arg _label "${HEAL_LABEL}" \\\n\
		--arg _value "${HEAL_VALUE}" \\\n\
	| xargs -tr -L1 -I% -P${THREADS:-$(nproc)} -- \\\n\
		"${SHELL}" -c "call POST /containers/%/restart" \n\
	touch /check\n\
	continue\n\
done\n' | tee "${MAIN}"

CMD "${SHELL}" "${MAIN}"

HEALTHCHECK \
	--start-period=5s \
	--interval=10s \
	--timeout=5s \
	--retries=3 \
	CMD bash "${HEALTH}" "/check"

LABEL "${HEAL_LABEL}"="${HEAL_VALUE}"
