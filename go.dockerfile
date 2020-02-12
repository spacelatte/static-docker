#!/usr/bin/env -S docker build --compress -t pvtmert/go -f

FROM debian

RUN apt update
RUN apt install -y \
	gcc git curl make

ARG MAJ=1
ARG MIN=13
ARG PATCH=7
ARG VERSION=${MAJ}.${MIN}.${PATCH}
ARG ARCH=amd64
ARG OS=linux
RUN curl -#L https://dl.google.com/go/go${VERSION}.${OS}-${ARCH}.tar.gz \
	| tar --strip=0 -xzC /usr/local

ENV PATH "${PATH}:/usr/local/go/bin"
