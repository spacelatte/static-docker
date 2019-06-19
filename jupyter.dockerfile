#!/usr/bin/env docker build --compress -t pvtmert/jupyter -f

FROM debian:stable

ARG PASSWORD
ENV PORT 8888

WORKDIR /data

RUN apt update && apt install -y python3-pip python3-dev python3

RUN pip3 install jupyter ipython numpy scipy tensorflow keras sklearn pandas

RUN mkdir -p "${HOME:-/root}/.jupyter"

RUN printf "%s\n%s\n" "${PASSWORD}" "${PASSWORD}" \
	| jupyter notebook password

CMD jupyter notebook --allow-root --port=${PORT} --ip=0.0.0.0
