#!/usr/bin/env -S docker build --compress -t pvtmert/websocketd -f

FROM alpine:latest

ENV VERSION 0.3.0

ADD https://github.com/joewalnes/websocketd/releases/download/v$VERSION/websocketd-$VERSION-linux_amd64.zip \
	websocketd.zip

#RUN apt update && apt install -y unzip && apt clean
RUN ln -s lib lib64
RUN ln -s ld-musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2

RUN unzip websocketd.zip websocketd

WORKDIR /data

ENTRYPOINT [ "/websocketd" ]
CMD        [ "--help" ]
