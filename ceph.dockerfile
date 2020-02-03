#!/usr/bin/env -S docker build --compress -t pvtmert/ceph -f

FROM debian

RUN apt update
RUN apt install -y build-essential git

WORKDIR /data
RUN git clone --depth=1 https://github.com/ceph/ceph.git ./

