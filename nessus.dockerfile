#!/usr/bin/env -S docker build --compress -t pvtmert/nessus -f

FROM debian:stable

RUN apt update
RUN apt install -y curl

WORKDIR /data
RUN curl -#Lo nessus.deb \
	"https://www.tenable.com/downloads/api/v1/public/pages/nessus/downloads/10838/download?i_agree_to_tenable_license_agreement=true"

RUN test -e nessus.deb
RUN dpkg -i nessus.deb

EXPOSE 8834
CMD service nessusd start; service nessusd status; \
	until test -e /opt/nessus/var/nessus/logs/www_server.log; do sleep 1; done; \
	tail -f \
		/opt/nessus/var/nessus/logs/backend.log \
		/opt/nessus/var/nessus/logs/www_server.log
