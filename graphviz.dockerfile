#!/usr/bin/env -S docker build --compress -t pvtmert/graphviz -f

FROM debian

WORKDIR /data

RUN apt update
RUN apt install -y graphviz

# :D
