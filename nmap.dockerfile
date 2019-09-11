#!/usr/bin/env -S docker build --compress -t pvtmert/nmap -f

FROM debian

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
RUN (cd $DIR && ./configure --without-zenmap && make -j $(nproc))

#ENV PATH="$PATH:$DIR"
#ENTRYPOINT [ "nmap" ]
#CMD [ "--help" ]

ENV PATH=$PATH:$DIR:$DIR/nping:$DIR/ncat
CMD nmap
