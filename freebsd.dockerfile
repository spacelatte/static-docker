#!/usr/bin/env -S docker build -t pvtmert/freebsd -f

FROM debian:testing as build

RUN apt update
RUN apt install -y \
	unzip curl clang git lld lldb llvm freebsd-buildutils freebsd-glue

#WORKDIR /data
#RUN git clone --depth=1 --no-tags \
#	https://github.com/freebsd/freebsd.git \
#	.

WORKDIR /tmp
RUN curl -#Lo repo.zip https://github.com/freebsd/freebsd/archive/master.zip
#RUN unzip -od . repo.zip
#RUN rm -f repo.zip
#RUN mv -f freebsd-master /data

#FROM scratch
#COPY --from=build / /
#CMD bash
WORKDIR /data
