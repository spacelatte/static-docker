#!/usr/bin/env docker build --compress -t pvtmert/shadowsocks -f

FROM debian:stable

#ENV CC=clang
ENV DIR=shadowsocks
ENV REPO=https://github.com/shadowsocks/shadowsocks-libev.git

WORKDIR /data

RUN apt update && apt install -y \
	build-essential clang make git autoconf automake pkg-config libtool asciidoc \
	libev-dev libsodium-dev libpcre3-dev libmbedtls-dev gettext libc-ares-dev \
	&& apt clean

RUN git clone --recursive $REPO $DIR
RUN (cd $DIR; ./autogen.sh && ./configure --enable-static)

CMD make -C $DIR -j -
