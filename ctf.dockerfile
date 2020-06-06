#!/usr/bin/env -S docker build --compress -t pvtmert/ctf -f

FROM debian:stable

RUN apt update
RUN apt dist-upgrade -y
RUN apt install -y \
	bsdmainutils \
	build-essential \
	clang \
	exiftool \
	fluxbox \
	gcc \
	make \
	nasm \
	vnc4server \
	--no-install-recommends
