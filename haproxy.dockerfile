#!/usr/bin/env docker build --compress -t pvtmert/haproxy -f

FROM centos:6

RUN yum update -y && \
	yum install -y haproxy && \
	yum clean all
