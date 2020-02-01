#!/usr/bin/env -S docker build --compress -t pvtmert/ipython -f

FROM alpine

RUN apk add --no-cache bind-tools python3
RUN pip3 install -U ipython

WORKDIR /data
CMD ipython
