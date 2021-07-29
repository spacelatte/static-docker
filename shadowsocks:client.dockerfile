#!/usr/bin/env -S docker build --compress -t pvtmert/shadowsocks:client -f

# example: docker run --rm -itp 1080:1080 \
# -e SERVER=my.shadow.host \
# -e PASSWORD=my.password  \
# pvtmert/shadowsocks:client

FROM alpine:latest

RUN apk add --no-cache py3-pip
RUN python3 -m pip install -U shadowsocks-py

ENV LOCAL_PORT  1080
ENV REMOTE_PORT 8388
ENV SERVER "host.docker.internal"
ENV PASSWORD "verysecretpassword"
CMD "sslocal" \
	"--fast-open" \
	"-b" "0.0.0.0" \
	"-l" "${LOCAL_PORT}" \
	"-s" "${SERVER}" \
	"-p" "${REMOTE_PORT}" \
	"-k" "${PASSWORD}"

EXPOSE ${LOCAL_PORT}/tcp
