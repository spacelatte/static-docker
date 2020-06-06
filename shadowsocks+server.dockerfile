#!/usr/bin/env -S docker build --compress -t pvtmert/shadowsocks:server -f

# example: docker run --rm -ite PASSWORD=my.password \
# -p 8388:8388/tcp -p 8388:8388/udp pvtmert/shadowsocks:server

FROM alpine:latest

RUN apk add --no-cache py3-pip
RUN apk add --no-cache libressl openssl
RUN python3 -m pip install -U shadowsocks-py


ENV PORT 8388
ENV LISTEN "0.0.0.0"
ENV PASSWORD "verysecretpassword"
CMD "ssserver"    \
	"--fast-open"  \
	"-p" "${PORT}"  \
	"-s" "${LISTEN}" \
	"-k" "${PASSWORD}"

EXPOSE ${PORT}/tcp
EXPOSE ${PORT}/udp
