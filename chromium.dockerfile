#!/usr/bin/env -S docker build --compress -t pvtmert/chromium -f

FROM debian

RUN apt update
RUN apt install -y chromium

# default-jdk-headless openjdk-11-jdk-headless

ENV DISPLAY :0
EXPOSE 9222

ENTRYPOINT [                              \
	"chromium",                           \
	"--no-sandbox",                       \
	"--remote-debugging-address=0.0.0.0", \
	"--remote-debugging-port=9222"        \
]
CMD [                   \
	"--headless",       \
	"http://google.com" \
]

#CMD chromium \
#	--no-sandbox \
#	--headless \
#	--remote-debugging-address=0.0.0.0 \
#	--remote-debugging-port=9222 \
#	http://google.com \
#	& wait
