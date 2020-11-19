#!/usr/bin/env -S docker build --compress -t pvtmert/dind:latest -f

ARG BASE=centos


FROM debian:latest AS debian

RUN apt update
RUN apt install -y \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg-agent \
	software-properties-common

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository \
	"deb https://download.docker.com/linux/debian $(lsb_release -cs) stable"
RUN apt-get update
RUN apt-get install -ydocker-ce docker-ce-cli containerd.io

FROM ubuntu:latest AS ubuntu

RUN apt update
RUN apt install -y \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg-agent \
	software-properties-common

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository \
	"deb https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

RUN apt update
RUN apt install -y docker-ce docker-ce-cli containerd.io

FROM centos:latest AS centos

ADD \
	"https://download.docker.com/linux/centos/docker-ce.repo" \
	"/etc/yum.repos.d/docker.repo"

RUN yum install -y docker-ce docker-ce-cli containerd.io

FROM scratch AS final
COPY --from=${BASE} / /
