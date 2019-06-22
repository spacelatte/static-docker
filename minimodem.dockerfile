#!/usr/bin/env docker build --compress -t pvtmert/minimodem -f

FROM debian

RUN apt update && apt install -y minimodem

