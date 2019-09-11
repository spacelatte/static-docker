#!/usr/bin/env -S docker build --compress -t pvtmert/tableau -f

FROM debian

RUN apt update
RUN apt install -y \
	procps openjdk-8-jre \
	fontconfig fuse net-tools bash-completion gdb freeglut3 \
	libegl1-mesa libfreetype6 libfuse2 libgssapi-krb5-2 \
	libxcomposite1 libxrender1 libxslt1.1 lsb-core

WORKDIR /data

ENV pkg_tabcmd https://downloads.tableau.com/esdalt/2018.3.0/tableau-tabcmd-2018-3-0_all.deb
ENV pkg_server https://downloads.tableau.com/tssoftware/tableau-server-2018-3-0_amd64.deb

ADD $pkg_tabcmd ./tableau-tabcmd.deb
ADD $pkg_server ./tableau-server.deb

# hack
RUN mkdir -p /run/systemd/system
RUN echo > /usr/local/bin/sysctl && chmod +x /usr/local/bin/sysctl
RUN echo 'for i in {0..9}; do echo $i,$i; done' > /usr/local/bin/lscpu && \
	chmod +x /usr/local/bin/lscpu
RUN echo 'echo; echo mem: 32768' > /usr/local/bin/free && \
	chmod +x /usr/local/bin/free

RUN dpkg -i tableau-tabcmd.deb tableau-server.deb || true

#RUN /opt/tableau/tabcmd/bin/tabcmd --accepteula
#RUN /opt/tableau/tableau_server/packages/scripts.20183.18.1019.1426/initialize-tsm --accepteula

RUN ln -s /opt/tableau/tabcmd/bin/tabcmd /usr/local/bin/tabcmd

CMD su -
