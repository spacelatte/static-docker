#!/usr/bin/env -S docker build --compress -t pvtmert/goaccess -f

ARG PREFIX=/opt
ARG VERSION=1.4
FROM centos:7 AS build

RUN yum install -y gcc make \
	libmaxminddb-devel \
	{ncurses,openssl}-{static,devel}

WORKDIR /data
ARG VERSION
RUN curl -#L "https://tar.goaccess.io/goaccess-${VERSION}.tar.gz" \
	| tar --strip=1 -xzC .

ARG PREFIX
RUN ./configure \
	--with-getline \
	--with-openssl \
	--enable-utf8 \
	--enable-geoip=mmdb \
	--prefix="${PREFIX}"

RUN make -C . -j $(nproc)
RUN make -C . install

FROM centos:7
RUN yum install -y libmaxminddb {openssl,ncurses}-libs
ARG PREFIX
COPY --from=build "${PREFIX}" "${PREFIX}"
ENV PATH "${PREFIX}/bin:${PATH}"
ENTRYPOINT [ "goaccess" ]
CMD        [ ]
