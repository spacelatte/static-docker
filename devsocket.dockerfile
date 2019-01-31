#!/usr/bin/env docker build -t pvtmert/devsocket -f

FROM pvtmert/websocketd

RUN apk add inotify-tools

#VOLUME /data
WORKDIR /data

CMD [ "--port=80", "--staticdir=/data", "--", "inotifywait", "-re", "modify", "." ]
