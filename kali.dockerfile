#!/usr/bin/env docker build --compress -t pvtmert/kali -f

FROM kalilinux/kali-linux-docker

RUN apt update && apt install -y kali-linux-all && apt clean

CMD su -
