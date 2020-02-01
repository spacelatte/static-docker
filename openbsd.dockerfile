#!/usr/bin/env -S docker build -t pvtmert/openbsd -f

FROM debian:testing as build

RUN apt update
RUN apt install -y \
	unzip curl clang git lld lldb llvm freebsd-buildutils freebsd-glue

#WORKDIR /data
#RUN git clone --depth=1 --no-tags \
#	https://github.com/openbsd/src.git \
#	.

WORKDIR /tmp
RUN curl -#Lo repo.zip https://github.com/openbsd/src/archive/master.zip
#RUN unzip -od . repo.zip
#RUN rm -f repo.zip
#RUN mv -f src-master /data

#FROM scratch
#COPY --from=build / /
#CMD bash
WORKDIR /data
