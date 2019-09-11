#!/usr/bin/env -S docker build --compress -t pvtmert/beastiebox -f

FROM debian

RUN apt update
RUN apt install -y \
	build-essential cvs

WORKDIR /data
ENV REPO repo

RUN cvs -d :pserver:anonymous@beastiebox.cvs.sourceforge.net:/cvsroot/beastiebox co "${REPO}"

