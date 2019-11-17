#!/usr/bin/env -S docker build --compress -t pvtmert/notebook -f

FROM alpine:latest

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" \
	| tee -a /etc/apk/repositories

RUN apk add --no-cache \
	build-base linux-headers \
	lapack-dev gfortran \
	hdf5-dev python3-dev

RUN pip3 install -U pip        || true
RUN pip3 install -U numpy      || true
RUN pip3 install -U scipy      || true
RUN pip3 install -U keras      || true
RUN pip3 install -U ipython    || true
RUN pip3 install -U jupyter    || true
#RUN pip3 install -U tensorflow || true

EXPOSE 80
WORKDIR /data
CMD jupyter notebook \
	--allow-root \
	--no-browser \
	--ip=0.0.0.0 \
	--port=80 \
	--NotebookApp.token= \
	--NotebookApp.allow_origin='*'

FROM debian:latest

RUN apt update
RUN apt install -y \
	build-essential \
	python3-dev \
	python3-pip \
	vim nano less

RUN pip3 install -U pip        || true
RUN pip3 install -U numpy      || true
RUN pip3 install -U scipy      || true
RUN pip3 install -U keras      || true
RUN pip3 install -U ipython    || true
RUN pip3 install -U jupyter    || true
RUN pip3 install -U tensorflow || true

EXPOSE 80
WORKDIR /data
CMD jupyter notebook \
	--allow-root \
	--no-browser \
	--ip=0.0.0.0 \
	--port=80 \
	--NotebookApp.token= \
	--NotebookApp.allow_origin='*'
