#!/usr/bin/env -S docker build --compress -t pvtmert/darling -f

ARG BASE=debian:stable
FROM ${BASE} AS build

RUN apt update
RUN apt install -y      \
	bison               \
	clang               \
	cmake               \
	flex                \
	git                 \
	libavcodec-dev      \
	libavformat-dev     \
	libavresample-dev   \
	libbsd-dev          \
	libc6-dev-i386      \
	libcairo2-dev       \
	libcap2-bin         \
	libdbus-1-dev       \
	libegl1-mesa-dev    \
	libfontconfig1-dev  \
	libfreetype6-dev    \
	libfuse-dev         \
	libgif-dev          \
	libgl1-mesa-dev     \
	libglu1-mesa-dev    \
	libpulse-dev        \
	libtiff5-dev        \
	libudev-dev         \
	libxcursor-dev      \
	libxkbfile-dev      \
	libxml2-dev         \
	libxrandr-dev       \
	linux-headers-amd64 \
	pkg-config          \
	python2             \
	xz-utils            \
	--no-install-recommends

ENV CC   clang
ENV DIR  repo
ENV REPO https://github.com/darlinghq/darling.git

WORKDIR /data
RUN git clone -q --progress --recursive "${REPO}" "${DIR}"
RUN mkdir build && (cd build && cmake ../repo);
RUN make -C build lkm
RUN make -C build
RUN make -C build install
RUN make -C build lkm_install

FROM ${BASE}
COPY --from=build /data/repo/darkstat ./
ENTRYPOINT [ "./darkstat" ]
CMD        [ ]
