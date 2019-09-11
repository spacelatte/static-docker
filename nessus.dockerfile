#!/usr/bin/env -S docker build --compress -t pvtmert/nessus -f

FROM debian

EXPOSE  8834
WORKDIR /data

ADD "https://www.tenable.com/downloads/pages/60/downloads/9339/download_file?utf8=%E2%9C%93&i_agree_to_tenable_license_agreement=true&commit=I+Agree" \
	nessus.deb

RUN dpkg -i nessus.deb

CMD service nessusd start; service nessusd status; \
	until test -e /opt/nessus/var/nessus/logs/www_server.log; do sleep 1; done; \
	tail -f \
		/opt/nessus/var/nessus/logs/backend.log \
		/opt/nessus/var/nessus/logs/www_server.log
