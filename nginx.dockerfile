#!/usr/bin/env docker build --compress -t pvtmert/nginx -f

FROM nginx:latest

VOLUME /etc/nginx/conf.d
VOLUME /srv/www

RUN apt update && apt install -y \
	openssl ca-certificates \
	&& apt clean


ENV DAYS 3650
WORKDIR /etc/ssl/private
RUN openssl genrsa -out priv.key 4096
RUN openssl req -new -key priv.key -out req.csr -days $DAYS -subj '/CN=*'
RUN openssl x509 -req -in req.csr -signkey priv.key -out cert.crt -days $DAYS

RUN cat priv.key cert.crt > /etc/nginx/server.cert

WORKDIR /etc/nginx/conf.d
ADD https://gist.githubusercontent.com/pvtmert/ee207236cd6f99f4498dede3c0608b17/raw/8900c94daa1f31c555ea419ee9f465a5029a4f6f/nginx.conf default.conf

WORKDIR /srv
