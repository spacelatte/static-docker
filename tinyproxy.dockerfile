#!/usr/bin/env -S docker build --compress -t pvtmert/tinyproxy -f

FROM debian

RUN apt update && \
	apt install -y \
	build-essential git make automake asciidoc

ENV PORT 80
ENV REPO https://github.com/tinyproxy/tinyproxy.git

EXPOSE ${PORT}
WORKDIR /data

RUN git clone --depth=1 $REPO && \
	(cd tinyproxy; bash autogen.sh; ./configure)

RUN make -C tinyproxy -j $(nproc) && \
	make -C tinyproxy -j $(nproc) install

RUN ( \
		echo "user         root";    \
		echo "group        root";    \
		echo "port         $PORT";   \
		echo "listen       0.0.0.0"; \
		echo "bindsame     yes";     \
		echo "maxclients   99";      \
		echo "startservers 9";       \
	) | tee -a tinyproxy.conf

ENTRYPOINT [ "tinyproxy", "-d" ]
CMD        [ "-c" , "tinyproxy.conf" ]
