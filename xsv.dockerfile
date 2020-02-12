#!/usr/bin/env -S docker build --compress -t pvtmert/xsv -f

ARG BASE=alpine
FROM ${BASE} as build

RUN apk add --no-cache \
	cargo rust make git

WORKDIR /data
RUN git clone --depth 1 https://github.com/burntsushi/xsv.git .
RUN make -j$(nproc) release


FROM ${BASE}
COPY --from=build /data/target/release/xsv ./
ENTRYPOINT [ "./xsv"  ]
CMD        [ "--help" ]


