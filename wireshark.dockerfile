#!/usr/bin/env -S docker build --compress -t pvtmert/wireshark -f

FROM debian:stable

RUN apt update
RUN apt install -y \
	wireshark

#VOLUME /tmp/.X11-unix
WORKDIR /data
ENV DISPLAY :0

ENTRYPOINT [ "wireshark" ]
CMD        [ ]
