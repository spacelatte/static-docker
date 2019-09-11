#!/usr/bin/env -S docker build --compress -t pvtmert/nginx -f

FROM nginx:latest

RUN apt update && apt install -y \
	openssl ca-certificates \
	&& apt clean

VOLUME /etc/nginx/conf.d
VOLUME /srv/www

ARG DAYS=3650
WORKDIR /etc/ssl/private
RUN openssl genrsa -out server.key 4096
RUN openssl req -new -x509 -sha256 -key server.key -out server.crt \
	-days $DAYS -subj '/CN=*'
RUN cat server.crt server.key > /etc/nginx/server.cert

ADD https://gist.githubusercontent.com/pvtmert/ee207236cd6f99f4498dede3c0608b17/raw/nginx.conf \
	/etc/nginx/conf.d/default.conf

WORKDIR /srv
