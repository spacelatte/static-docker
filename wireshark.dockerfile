#!/usr/bin/env -S docker build --compress -t pvtmert/wireshark -f

FROM debian:stable

RUN apt update
RUN apt install -y \
	wireshark

WORKDIR /home
ENV DISPLAY :0

VOLUME /tmp/.X11-unix
ENTRYPOINT [ "wireshark" ]
CMD        [ ]
