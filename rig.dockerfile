#!/usr/bin/env -S docker build --compress -t pvtmert/rig -f

ARG BASE=debian:stable
FROM ${BASE} AS build

RUN apt update
RUN apt install -y build-essential curl git gcc

WORKDIR /data
RUN curl --compressed -#L "https://liquidtelecom.dl.sourceforge.net/project/rig/rig/1.11/rig-1.11.tar.gz" \
	| tar --strip=1 -xzC .

RUN (echo "#include <cstring>"; cat rig.cc ) > rig.cc.new && mv rig.cc.new rig.cc
RUN mkdir -p /usr/local/man/man6
RUN make -j$(nproc) && make -j$(nproc) install

FROM ${BASE}
COPY --from=build /usr/local /usr/local
ENTRYPOINT [ "rig" ]
CMD        [ ]
