#!/usr/bin/env -S docker build --compress -t pvtmert/kali -f

FROM kalilinux/kali-linux-docker

RUN apt update
RUN apt install -y kali-linux-all

CMD su -
