#!/usr/bin/env -S docker build --compress -t pvtmert/toolbox -f

ARG BASE=debian:stable
FROM ${BASE} as build

RUN apt update
RUN apt install -y \
	build-essential git clang make automake autoconf \
	pkg-config ninja-build

ENV CC   clang
ENV DIR  repo
ENV REPO https://android.googlesource.com/platform/system/core

WORKDIR /data
RUN git clone -q --progress --depth=1 "${REPO}" "${DIR}"

#RUN (cd $DIR; autoreconf -i) && $DIR/configure
#CMD make -C . -j $(nproc)
