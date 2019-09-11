#!/usr/bin/env -S docker build --compress -t pvtmert/icestorm -f

FROM debian

RUN apt update
RUN apt install -y \
	build-essential clang bison flex libreadline-dev \
	gawk tcl-dev libffi-dev git mercurial graphviz   \
	xdot pkg-config python python3 libftdi-dev

WORKDIR /data

RUN git clone --depth=1 https://github.com/cliffordwolf/icestorm.git icestorm
RUN make -C icestorm -j $(nproc) all install

RUN git clone --depth=1 https://github.com/cseed/arachne-pnr.git arachne-pnr
RUN make -C arachne-pnr -j $(nproc) install

RUN git clone --depth=1 https://github.com/cliffordwolf/yosys.git yosys
RUN make -C yosys -j $(nproc) install

RUN git clone --depth=1 https://github.com/tinyfpga/TinyFPGA-B-Series.git tinyfpga-b
