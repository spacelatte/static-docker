#!/usr/bin/env docker build --compress -t pvtmert/heirloom -f

FROM debian:stable

#ENV CC      clang
ENV DIR     heirloom
ENV REPO    a.cvs.sourceforge.net::cvsroot/heirloom/
ENV CVSROOT /data/heirloom

WORKDIR /data

RUN apt update && apt install -y \
	libssl-dev build-essential rsync clang cvs \
	&& apt clean

RUN rsync -aiz --progress $REPO $DIR
RUN find $DIR -iname "#*" -delete
RUN mkdir -p cvs && cd cvs && \
	bash -c 'cvs checkout -P heirloom{,-sh,-pkgtools,-devtools,-doctools}'

RUN ln -s bin   /usr/ucb
RUN ln -s local /usr/ccs
RUN ln -s ../bin/bash /sbin/sh
RUN make -C cvs/heirloom-devtools -j $(nproc) || true
RUN make -C cvs/heirloom-pkgtools -j $(nproc) || true
RUN make -C cvs/heirloom-doctools -j $(nproc) || true
RUN make -C cvs/heirloom-sh       -j $(nproc) || true
RUN make -C cvs/heirloom          -j $(nproc) || true

COPY build.sh ./cvs/
RUN cd cvs && bash build.sh
