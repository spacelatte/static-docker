#!/usr/bin/env -S docker build --compress -t pvtmert/openfortivpn -f

FROM debian:stable

RUN apt update
RUN apt install -y \
	openfortivpn

ENTRYPOINT [ "openfortivpn" ]
CMD        [ "--help"       ]
