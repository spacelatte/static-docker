#!/usr/bin/env -S docker build --compress -t pvtmert/haproxy -f

FROM centos:7

RUN yum update -y
RUN yum install -y haproxy

