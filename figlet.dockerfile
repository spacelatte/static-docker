#!/usr/bin/env -S docker build --compress -t pvtmert/figlet -f

ARG BASE=debian:stable
FROM ${BASE} as build

RUN apt update
RUN apt install -y \
	build-essential curl

ARG VERSION=2.2.5
WORKDIR /data
RUN curl -#L ftp://ftp.figlet.org/pub/figlet/program/unix//figlet-${VERSION}.tar.gz \
	| tar --strip=1 -xz

ARG PREFIX=/opt
RUN make -j$(nproc) prefix="${PREFIX}" all install

FROM ${BASE} as runtime
COPY --from=build /opt /opt
ENTRYPOINT [ "/opt/bin/figlet" ]
CMD        [ "--help" ]
