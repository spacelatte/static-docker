#!/usr/bin/env docker build --compress -t pvtmert/cloud-init -f

FROM debian:stable

WORKDIR /data

RUN apt update && apt install -y \
	nano less curl unzip xz-utils cloud-init \
	&& apt clean

CMD cloud-init init; bash
