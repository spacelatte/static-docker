#!/usr/bin/env -S docker build --compress -t pvtmert/tinyproxy -f

ARG PORT=80
ARG BASE=debian:stable
FROM ${BASE} AS build

RUN apt update && \
	apt install -y \
	build-essential git make automake asciidoc

ENV DIR .
ENV REPO https://github.com/tinyproxy/tinyproxy.git

WORKDIR /data
RUN git clone --depth=1 "${REPO}" "${DIR}"
RUN (cd "${DIR}" && bash autogen.sh) && "${DIR}/configure"

RUN make -C . -j $(nproc) && \
	make -C . -j $(nproc) install

FROM ${BASE}
COPY --from=build /data/src/tinyproxy      ./
COPY --from=build /data/etc/tinyproxy.conf ./
ARG PORT
RUN ( \
		echo "user         root";    \
		echo "group        root";    \
		echo "port         ${PORT}"; \
		echo "listen       0.0.0.0"; \
		echo "bindsame     yes";     \
		echo "maxclients   99";      \
		echo "startservers 9";       \
	) | tee -a tinyproxy.conf

EXPOSE ${PORT}
ENTRYPOINT [ "./tinyproxy", "-d" ]
CMD        [ "-c" , "tinyproxy.conf" ]
