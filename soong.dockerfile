#!/usr/bin/env docker build --compress -t pvtmert/soong -f

FROM debian:stable

ENV CC   clang
ENV DIR  soong
ENV REPO https://android.googlesource.com/platform/build/soong

WORKDIR /data

RUN apt update && apt install -y \
	build-essential git clang make automake autoconf \
	pkg-config ninja-build \
	&& apt clean

RUN git clone -q --progress --depth 1 $REPO $DIR

#RUN (cd $DIR; autoreconf -i) && $DIR/configure

#CMD make -C . -j $(nproc)
