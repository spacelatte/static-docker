#!/usr/bin/env -S docker build --compress -t pvtmert/darkstat -f

ARG BASE=debian:stable
FROM ${BASE} AS build

RUN apt update
RUN apt install -y \
	build-essential \
	git \
	clang \
	make \
	automake \
	autoconf \
	libpcap-dev \
	zlib1g-dev \
	xxd \
	--no-install-recommends

ENV CC   clang
ENV DIR  repo
ENV REPO https://www.unix4lyfe.org/git/darkstat
# https://unix4lyfe.org/darkstat/darkstat-3.0.719.tar.bz2

WORKDIR /data
RUN git clone -q --progress $REPO $DIR
RUN cd $DIR; autoreconf -i
RUN cd $DIR; ./configure LDFLAGS=-static
RUN make -C $DIR -j $(nproc)

FROM ${BASE}
COPY --from=build /data/repo/darkstat ./
ENTRYPOINT [ "./darkstat" ]
CMD        [ ]
