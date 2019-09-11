#!/usr/bin/env -S docker build --compress -t pvtmert/redis-stat -f

FROM ruby

RUN gem install redis-stat

ENTRYPOINT [ "redis-stat" ]
CMD        [ "--help" ]
