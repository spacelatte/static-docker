#!/usr/bin/env -S docker build --compress -t pvtmert/shadowsocks -f

ARG BASE=debian:stable
FROM ${BASE} as build

RUN apt update
RUN apt install -y \
	build-essential clang make git autoconf automake pkg-config libtool asciidoc \
	libev-dev libsodium-dev libpcre3-dev libmbedtls-dev gettext libc-ares-dev

ENV CC   clang
ENV DIR  repo
ENV REPO https://github.com/shadowsocks/shadowsocks-libev.git

WORKDIR /data
RUN git clone --depth=1 --recursive "${REPO}" "${DIR}"
RUN (cd "${DIR}"; ./autogen.sh && ./configure --enable-static)
RUN make -C "${DIR}" -j $(nproc)

FROM ${BASE}
COPY --from=build /data/repo ./
