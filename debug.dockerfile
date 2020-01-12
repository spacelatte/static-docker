#!/usr/bin/env -S docker build --compress -t pvtmert/debug -f

FROM debian:10

# you may use lldb
ARG DEBUGGER=gdb

RUN apt update
RUN apt install -y \
	binutils valgrind ${DEBUGGER}

WORKDIR /data
ENV DEBUGGER ${DEBUGGER}
CMD ${DEBUGGER}
#ENTRYPOINT [ ${DEBUGGER} ]
#CMD        [ "--help" ]
