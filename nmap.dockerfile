#!/usr/bin/env docker build --compress -t pvtmert/nmap -f

FROM debian:stable

ENV CC   clang
ENV DIR  nmap
ENV REPO https://svn.nmap.org/nmap

WORKDIR /data

RUN apt update && apt install -y autoconf automake \
	build-essential clang make subversion ca-certificates python-dev \
	libpcap-dev libpcre2-dev libpcre3-dev liblinear-dev libssl-dev liblua5.3-dev \
	&& apt clean

RUN svn co $REPO $DIR

RUN (cd $DIR && ./configure && make -j $(nproc))

#ENV PATH="$PATH:$DIR"
#ENTRYPOINT [ "nmap" ]
#CMD [ "--help" ]

ENV PATH=$PATH:$DIR:$DIR/nping:$DIR/ncat
CMD nmap
