#!/usr/bin/env docker build --compress -t pvtmert/rsync -f

FROM debian:stable

ENV CC   clang
ENV DIR  rsync
ENV REPO git://git.samba.org/rsync.git

WORKDIR /data

RUN apt update && apt install -y \
	rsync librsync-dev build-essential clang \
	make git autoconf automake pkg-config \
	&& apt clean

RUN git clone --recursive $REPO $DIR
RUN (cd $DIR && ./configure \
	--enable-static --with-included-popt --with-included-zlib --disable-ipv6)

CMD make -C $DIR -j $(nproc) && $DIR/rsync
