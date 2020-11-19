#!/usr/bin/env -S docker build --compress -t pvtmert/curl -f

ARG BASE=debian:stable
FROM ${BASE} AS build

RUN apt update
RUN apt install -y \
	automake bison build-essential clang \
	libevent-dev git pkg-config libncurses5-dev

ENV CC   clang
ENV DIR  repo
ENV REPO https://github.com/curl/curl.git

WORKDIR /home

RUN apt install -y cmake libssl-dev libtool§ shtool \
	libssh-dev zlib1g-dev libnghttp2-dev librtmp-dev libzstd-dev
RUN git clone -q --progress --depth=1 "${REPO}" "${DIR}"
RUN cd "${DIR}" && autoreconf -i
RUN "${DIR}/configure" \
	--disable-shared \
	--enable-static  \
	--enable-manual  \
	--static \
	LDFLAGS='-static -dn'
RUN make -C "." -j "$(nproc)"

#FROM ${BASE}
#COPY --from=build /home/curl ./
#ENTRYPOINT [ "./curl" ]
#CMD        [ ]
