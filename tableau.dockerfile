#!/usr/bin/env docker build --compress -t pvtmert/tableau -f

FROM debian:stable

WORKDIR /data

ENV pkg_tabcmd https://downloads.tableau.com/esdalt/2018.3.0/tableau-tabcmd-2018-3-0_all.deb
ENV pkg_server https://downloads.tableau.com/tssoftware/tableau-server-2018-3-0_amd64.deb

ADD $pkg_tabcmd ./tableau-tabcmd.deb
ADD $pkg_server ./tableau-server.deb

RUN apt update && apt install -y \
	procps openjdk-8-jre \
	&& apt clean

RUN dpkg -i tableau-tabcmd.deb tableau-server.deb

RUN /opt/tableau/tabcmd/bin/tabcmd --accepteula

RUN ln -s /opt/tableau/tabcmd/bin/tabcmd /usr/local/bin/tabcmd

CMD su -
