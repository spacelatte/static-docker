#!/usr/bin/env -S docker build --compress -t pvtmert/zeronet -f

FROM debian

RUN apt update
RUN apt install -y \
	curl python3-pip

ENV PORT 43110
WORKDIR /data
EXPOSE ${PORT}

RUN curl -skL https://github.com/HelloZeroNet/ZeroNet/archive/py3/ZeroNet-py3.tar.gz \
	| tar --strip-components=1 -xz

RUN pip3 install -r requirements.txt

CMD python3 zeronet.py --ui_ip 0.0.0.0 --ui_port ${PORT}

HEALTHCHECK \
	--timeout=10s \
	--interval=1m \
	--start-period=1s \
	CMD curl -skLfm1 http://0:${PORT}
