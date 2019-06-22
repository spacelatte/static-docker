#!/usr/bin/env docker build --compress -t pvtmert/beastiebox -f

FROM debian

WORKDIR /data

ENV REPO repo

RUN apt update && apt install -y \
	build-essential cvs

RUN cvs -d :pserver:anonymous@beastiebox.cvs.sourceforge.net:/cvsroot/beastiebox co "${REPO}"

