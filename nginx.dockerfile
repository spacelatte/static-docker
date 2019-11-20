#!/usr/bin/env -S docker build --compress -t pvtmert/nginx -f


#!/usr/bin/env -S docker build --compress -t pvtmert/nginx:centos-7 -f

FROM centos:7 as build

RUN yum update -y
RUN yum install -y gcc make pcre-devel pcre2-devel zlib-devel openssl-devel

ENV VER 1.17.4
WORKDIR /data
RUN curl -#sk "https://nginx.org/download/nginx-${VER}.tar.gz" \
	| tar --strip-components=1 -oxvz

RUN ./configure && make -j$(nproc) build install

FROM centos:7

WORKDIR /usr/local
COPY --from=build /usr/local/nginx ./nginx

#RUN ln -sf /dev/stderr /usr/local/nginx/logs/error.log
RUN ln -sf /dev/stdout /usr/local/nginx/logs/access.log
CMD ./nginx/sbin/nginx -g 'daemon off;'

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
