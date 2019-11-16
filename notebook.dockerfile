#!/usr/bin/env -S docker build --compress -t pvtmert/notebook -f

FROM alpine:edge

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" \
	| tee -a /etc/apk/repositories

RUN apk add --no-cache \
	build-base linux-headers \
	lapack-dev gfortran \
	hdf5-dev python3-dev

RUN pip3 install -U \
	ipython jupyter numpy scipy keras

EXPOSE 80
CMD jupyter notebook \
	--allow-root \
	--no-browser \
	--ip=0.0.0.0 \
	--port=80 \
	--NotebookApp.token= \
	--NotebookApp.allow_origin='*'

