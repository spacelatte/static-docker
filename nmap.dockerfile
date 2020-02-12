#!/usr/bin/env -S docker build --compress -t pvtmert/nmap -f

ARG BASE=debian:9
FROM ${BASE} AS build

RUN apt update
RUN apt install -y autoconf automake \
	build-essential clang make subversion ca-certificates python-dev \
	libpcap-dev libpcre2-dev libpcre3-dev liblinear-dev liblua5.3-dev \
	libz-dev libssh2-1-dev libssl-dev

WORKDIR /data

ENV CC   clang
ENV DIR  nmap
ENV REPO https://svn.nmap.org/nmap

RUN svn co $REPO $DIR
RUN (cd $DIR \
		&& ./configure --without-zenmap \
			LDFLAGS="-fPIC" \
			CFLAGS=" -fPIC" \
		&& make -j$(nproc) \
		&& make -j$(nproc) install \
	) || true

#ENV PATH="$PATH:$DIR"
#ENTRYPOINT [ "nmap" ]
#CMD [ "--help" ]

FROM ${BASE}
RUN apt update
RUN apt install -y libpcap0.8 libssh2-1 libssl1.1 liblinear3 liblua5.3
COPY --from=build /usr/local /usr/local
ENTRYPOINT [ "nmap" ]
CMD        [ ]
