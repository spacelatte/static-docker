#!/usr/bin/env -S docker build --compress -t pvtmert/tailscale -f

ARG BASE=debian:stable
FROM ${BASE}

RUN apt update
RUN apt install -y curl procps gnupg apt-transport-https

RUN curl -#L https://pkgs.tailscale.com/stable/debian/buster.gpg  \
	| apt-key add -
RUN curl -#L https://pkgs.tailscale.com/stable/debian/buster.list \
	| tee /etc/apt/sources.list.d/tailscale.list

RUN apt update
RUN apt install -y tailscale
RUN echo '#!/usr/bin/env bash\n\
ARGS=( "$@" )\n\
test -n "${AUTHKEY}" && ARGS+=( "--authkey=${AUTHKEY}" )\n\
trap "pkill -eP 1" RETURN EXIT TERM HUP INT\n\
tailscaled & sleep 5 && tailscale up "${ARGS[@]}" || pkill -eP 1 &\n\
wait\n' | tee /init.sh

ENTRYPOINT [ "bash", "-x", "/init.sh" ]
CMD        [ "--accept-dns=true", "--accept-routes=true", "--host-routes=true" ]
