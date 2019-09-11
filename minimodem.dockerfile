#!/usr/bin/env -S docker build --compress -t pvtmert/minimodem -f

FROM debian

RUN apt update
RUN apt install -y minimodem

