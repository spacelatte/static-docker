#!/usr/bin/env -S docker build --compress -t pvtmert/unbound -f

ARG PREFIX="/opt"
ARG BASE=debian:stable
FROM ${BASE} as build

RUN apt update
RUN apt install -y \
	curl build-essential \
	libssl-dev libexpat-dev

ARG VERSION=1.9.6
WORKDIR /data
RUN curl -#L "https://nlnetlabs.nl/downloads/unbound/unbound-${VERSION}.tar.gz" \
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
COPY --from=build /opt /opt
ENTRYPOINT [ "/opt/sbin/unbound" ]
CMD        [ ]
