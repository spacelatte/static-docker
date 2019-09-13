#!/usr/bin/env -S docker build --compress -t pvtmert/airflow -f

FROM centos/systemd

RUN yum update -y
RUN yum install -y epel-release gcc gcc-c++ wget curl

RUN yum install -y python36 python36-devel python36-pip \
	mysql mysql-devel postgresql postgresql-server

RUN pip3 install -U flask apache-airflow \
		apache-airflow[mysql] apache-airflow[postgresql] \
		JayDeBeApi pyexasol[pandas] psycopg2-binary

ENV PORT 8080
WORKDIR /data
EXPOSE ${PORT}

ADD https://gist.githubusercontent.com/pvtmert/9397d3ac65bbad6eb0d29bd1f9999b98/raw/airflow-init.sh \
	./init.sh

RUN ( \
		echo "(cd /data; test -e init.sh && bash init.sh)" ; \
	) | tee -a /etc/rc.local

RUN systemctl enable rc-local; \
	passwd -df root; \
	passwd -uf root; \
	chmod +x /etc/rc.local /etc/rc.d/rc.local


CMD init

#epel-release gcc gcc-c++ wget curl
#python36 python36-devel python36-pip postgresql postgresql-server
