#!/usr/bin/env -S docker build --compress -t pvtmert/sublime -f


ARG BASE=debian:stable
FROM ${BASE}

RUN apt update
RUN apt install -y \
	curl gnupg apt-transport-https

RUN curl -s https://download.sublimetext.com/sublimehq-pub.gpg \
	| apt-key add -

RUN echo "deb https://download.sublimetext.com/ apt/stable/" \
	| tee /etc/apt/sources.list.d/sublime-text.list

RUN apt update
RUN apt install -y \
	sublime-text

WORKDIR /data
ENV DISPLAY host.docker.internal:0
CMD subl
