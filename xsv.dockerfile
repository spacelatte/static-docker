#!/usr/bin/env -S docker build --compress -t pvtmert/xsv -f

FROM alpine as build

RUN apk add --no-cache \
	cargo rust make git

WORKDIR /data
RUN git clone --depth 1 https://github.com/burntsushi/xsv.git .
RUN make -j$(nproc) release


FROM alpine
COPY --from=build /data/target/release/xsv /usr/local/bin

ENTRYPOINT [ "/usr/local/bin/xsv" ]
CMD        [ "--help" ]


