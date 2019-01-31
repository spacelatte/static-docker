#!/usr/bin/env docker build --compress -t pvtmert/clustercontrol -f

FROM debian:stable

WORKDIR /data

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
	lsb-release wget python dmidecode bc gnupg software-properties-common \
	&& apt clean

ADD https://severalnines.com/scripts/install-cc?tO8kqTiuINLDD3AnjLvIkPc_RawPCNwCavdHZYZglYY, install-cc

RUN echo "mysql-server mysql-server/root_password password mypassword"       | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password mypassword" | debconf-set-selections

ENV S9S_ROOT_PASSWORD 1234
ENV S9S_CMON_PASSWORD 1234
ENV INNODB_BUFFER_POOL_SIZE 512

RUN apt install -y mysql-server && \
	bash install-cc             && \
	a2enmod proxy proxy_http proxy_wstunnel

CMD true && \
	service mysql       start; \
	service apache-htcacheclean start; \
	service apache2     start; \
	service cgmanager   start; \
	service cgproxy     start; \
	service cmon        start; \
	service cmon-ssh    start; \
	service cmon-cloud  start; \
	service cmon-events start; \
	service --status-all; \
	tail -f /var/log/cmon.log /var/log/apache2/access.log
