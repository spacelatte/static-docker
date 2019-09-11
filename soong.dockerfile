#!/usr/bin/env -S docker build --compress -t pvtmert/soong -f

FROM debian

RUN apt update 
RUN apt install -y \
	build-essential git clang make \
	automake autoconf pkg-config ninja-build

ENV CC   clang
ENV DIR  soong
ENV REPO https://android.googlesource.com/platform/build/soong
WORKDIR /data

RUN git clone -q --progress --depth=1 $REPO $DIR

#RUN (cd $DIR; autoreconf -i) && $DIR/configure

#CMD make -C . -j $(nproc)
