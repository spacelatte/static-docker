#!/usr/bin/env -S docker build --compress -t pvtmert/heroku -f

FROM node

WORKDIR /data
RUN npm install -g heroku

CMD bash
