#!/usr/bin/env -S docker build --compress -t pvtmert/cartography -f

FROM debian:latest

RUN apt update
RUN apt install -y \
	build-essential \
	git \
	python3-dev \
	python3-pip \
	--no-install-recommends

RUN python3 -m pip install -U pip git+https://github.com/lyft/cartography.git

WORKDIR /home
CMD bash
