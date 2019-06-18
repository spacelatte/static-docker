#!/usr/bin/env docker build --compress -t pvtmert/airflow -f

FROM centos:6

ENV PORT 8080

WORKDIR /data
EXPOSE ${PORT}

RUN yum update -y && \
	yum install -y epel-release centos-release-scl

RUN yum install -y gcc mysql mysql-devel rh-python36

RUN source scl_source enable rh-python36 && \
	pip3 install apache-airflow apache-airflow[mysql]

CMD source scl_source enable rh-python36 && airflow initdb && \
	echo scheduler webserver | xargs -n1 -P2 -- airflow
