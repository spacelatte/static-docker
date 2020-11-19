#!/usr/bin/env -S docker build --compress -t pvtmert/unbound -f

ARG PREFIX="/opt"
ARG VERSION=1.9.6
ARG ARCHIVEURL=https://nlnetlabs.nl/downloads/unbound/unbound-${VERSION}.tar.gz
ARG BASE=debian:stable
FROM ${BASE} AS build

RUN apt update
RUN apt install -y \
	curl build-essential \
	libssl-dev libexpat-dev

ARG ARCHIVEURL
WORKDIR /data
RUN curl --compressed -#L "${ARCHIVEURL}" \
	| tar --strip=1 -xzC "."

#RUN apt install -y

ARG PREFIX
RUN ./configure \
	--prefix="${PREFIX}" \
	--enable-static
#	--enable-fully-static
#	--enable-systemd
#	--enable-subnet

RUN make -C "." -j $(nproc) install

FROM "${BASE}"
RUN apt update
RUN apt install -y libssl1.1
ARG PREFIX
COPY --from=build "${PREFIX}" "${PREFIX}"
ENTRYPOINT [ "/opt/sbin/unbound" ]
CMD        [ ]
