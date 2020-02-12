#!/usr/bin/env -S docker build --compress -t pvtmert/haproxy -f

ARG BASE=centos:7
FROM ${BASE} as build

RUN yum install -y \
	git gcc make

# EG: 2.1.2
ARG VER=2.1
ARG SUB=2
WORKDIR /data
#RUN git clone -q --progress "http://git.haproxy.org/git/haproxy-2.1.git" "./"
RUN curl -#L "http://www.haproxy.org/download/${VER}/src/haproxy-${VER}.${SUB}.tar.gz" \
	| tar --strip=1 -xzC "."

RUN make -C . -j $(nproc) TARGET=generic

FROM ${BASE}
COPY --from=build /data/examples ./
COPY --from=build /data/haproxy  ./
ENTRYPOINT [ "./haproxy" ]
CMD        [ ]
