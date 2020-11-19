#!/usr/bin/env -S docker build --compress -t pvtmert/snidump -f

ARG BASE=debian:stable
FROM ${BASE} AS build

RUN apt update
RUN apt install -y \
	git clang build-essential \
	libpcap-dev libpcre++-dev

ENV CC   clang
ENV DIR  repo
ENV REPO https://github.com/kontaxis/snidump.git

WORKDIR /data
RUN git clone -q --progress --depth=1 "${REPO}" "${DIR}"
RUN make -C "${DIR}" -j $(nproc)

FROM ${BASE}
WORKDIR /data
COPY --from=build /data/repo/bin/* ./
ENTRYPOINT [ "snidump" ]
CMD        [ ]
