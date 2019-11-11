#!/usr/bin/env -S docker build --compress -t pvtmert/go -f

FROM debian

RUN apt update
RUN apt install -y gcc git curl make

ARG VERSION=1.13
ARG ARCH=amd64
ARG OS=linux
RUN curl -#L https://dl.google.com/go/go${VERSION}.${OS}-${ARCH}.tar.gz \
	| tar --strip-components=0 -xzC /usr/local

ENV PATH "$PATH:/usr/local/go/bin"
