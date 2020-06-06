#!/usr/bin/env -S docker build --compress -t pvtmert/dind:centos -f

FROM centos:7

RUN curl -#Lo /etc/yum.repos.d/docker.repo \
	https://download.docker.com/linux/centos/docker-ce.repo

RUN yum install -y docker-ce docker-ce-cli containerd.io
