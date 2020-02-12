#!/usr/bin/env -S docker build --compress -t pvtmert/ncdu -f

# well, fix kernel too old error :)
ARG BASE=debian:9
FROM ${BASE} as build

RUN apt update
RUN apt install -y \
	build-essential git clang make automake autoconf \
	pkg-config libncurses5-dev

ENV CC   clang
ENV DIR  repo
ENV REPO git://g.blicky.net/ncdu.git

WORKDIR /data
RUN git clone -q --progress --depth=1 $REPO $DIR
RUN (cd $DIR; autoreconf -i) && $DIR/configure LDFLAGS=-static
RUN make -C . -j $(nproc)

FROM ${BASE}
COPY --from=build /data/ncdu ./
ENTRYPOINT [ "./ncdu" ]
CMD        [ ]
