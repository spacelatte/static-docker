#!/usr/bin/env -S docker build --compress -t pvtmert/cartography -f

FROM debian:latest

RUN apt update
RUN apt install -y \
	build-essential \
	python3-dev \
	python3-pip \
	git

RUN pip3 install -U pip git+https://github.com/lyft/cartography.git

WORKDIR /home
CMD bash
