#!/usr/bin/env -S docker build --compress -t pvtmert/netcat -f

FROM debian:latest

RUN apt update
RUN apt install -y netcat

ENTRYPOINT [ "nc" ]
CMD        [ "-h" ]
