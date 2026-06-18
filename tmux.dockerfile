#!/usr/bin/env -S docker build --compress -t pvtmert/tmux:static -f

ARG BASE=debian:stable
FROM ${BASE} AS build

RUN apt update
RUN apt install -y \
	autoconf automake bison build-essential clang \
	git pkg-config libevent-dev libncurses-dev \
	libutf8proc-dev libsystemd-dev libjemalloc-dev \
	;

ENV CC   clang
ENV DIR  repo
ENV REPO https://github.com/tmux/tmux.git

WORKDIR /home

RUN git clone -q --progress --depth=1 "${REPO}" "${DIR}"
RUN env -C "${DIR}" bash autogen.sh
RUN "${DIR}/configure" \
	--enable-static \
	--enable-utf8proc \
	#--enable-systemd \
	#--enable-jemalloc \
	;

RUN make -C "." -j "$(nproc)"

FROM ${BASE}
COPY --from=build /home/tmux ./
ENTRYPOINT [ "./tmux" ]
CMD        [ ]
