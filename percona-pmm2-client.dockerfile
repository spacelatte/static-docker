#!/usr/bin/env -S docker build --compress -t pvtmert/pmm -f

FROM centos:6

RUN yum update
RUN yum install -y \
	https://repo.percona.com/yum/percona-release-latest.noarch.rpm

RUN yum install -y \
	pmm2-client

