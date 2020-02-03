#!/usr/bin/env -S docker build --compress -t pvtmert/shadowsocks -f

FROM debian:stable

RUN apt update
RUN apt install -y \
	build-essential clang make git autoconf automake pkg-config libtool asciidoc \
	libev-dev libsodium-dev libpcre3-dev libmbedtls-dev gettext libc-ares-dev

ENV CC   clang
ENV DIR  shadowsocks
ENV REPO https://github.com/shadowsocks/shadowsocks-libev.git

WORKDIR /data
RUN git clone --depth=1 --recursive $REPO $DIR
RUN (cd $DIR; ./autogen.sh && ./configure --enable-static)

CMD make -C $DIR -j $(nproc)
