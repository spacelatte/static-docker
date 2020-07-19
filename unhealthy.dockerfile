#!/usr/bin/env -S docker build --compress -t pvtmert/unhealthy -f

FROM busybox:latest

HEALTHCHECK \
	--start-period=1s \
	--interval=1s \
	--timeout=1s \
	--retries=2 \
	CMD false

ENTRYPOINT [ "sleep", "inf" ]
