#!/usr/bin/env docker build --compress -t pvtmert/ssproxy -f

FROM alpine:latest

RUN apk update && apk add py3-pip

RUN pip3 install --upgrade shadowsocks

ENTRYPOINT [ "sslocal", "-b", "0.0.0.0" ]
CMD [ "-s", "server", "-k", "password" ]
