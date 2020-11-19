#!/usr/bin/env -S docker build --compress -t pvtmert/devsocket -f

FROM pvtmert/websocketd

RUN apk add inotify-tools

WORKDIR /home
VOLUME  /home

CMD [ "--port=80", "--staticdir=.", "--", "inotifywait", "-re", "modify", "." ]

EXPOSE 80/tcp
