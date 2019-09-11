#!/usr/bin/env -S docker build --compress -t pvtmert/haproxy -f

FROM centos:6

RUN yum update -y
RUN yum install -y haproxy

