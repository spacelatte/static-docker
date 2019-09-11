#!/usr/bin/env -S docker build --compress -t pvtmert/ssproxy -f

FROM alpine

RUN apk update && apk add py3-pip
RUN pip3 install --upgrade shadowsocks

ENTRYPOINT [ "sslocal", "-b", "0.0.0.0" ]
CMD  [ "-s", "server", "-k", "password" ]
