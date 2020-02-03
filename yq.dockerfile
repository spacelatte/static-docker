#!/usr/bin/env -S docker build --compress -t pvtmert/yq -f

FROM debian:testing as build

RUN apt update
RUN apt install -y \
	git golang

WORKDIR /data
ENV GOPATH /data
ENV CGO_ENABLED 0
ENV GO111MODULE on
RUN go get -a -ldflags '-s' github.com/mikefarah/yq/v2

FROM scratch
COPY --from=build /data/bin/yq /yq
ENTRYPOINT [ "/yq" ]
CMD        [ "--help" ]
