#!/usr/bin/env -S docker build --compress -t pvtmert/minimodem -f

FROM debian:stable

RUN apt update
RUN apt install -y \
	git build-essential


RUN apt update
RUN apt install -y \
	build-essential git clang make \
	automake autoconf pkg-config \
	libfftw3f-dev libalsa-dev \
	libpulse-simple-dev libsndfile-dev

ENV CC   clang
ENV DIR  repo
ENV REPO https://github.com/kamalmostafa/minimodem.git
WORKDIR /data

RUN git clone -q --progress --depth=1 "${REPO}" "${DIR}"

#RUN (cd $DIR; autoreconf -i) && $DIR/configure

#CMD make -C . -j $(nproc)

