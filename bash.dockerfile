#!/usr/bin/env -S docker build --compress -t pvtmert/bash -f

ARG BASE=debian:testing
FROM ${BASE} AS build

RUN apt update
RUN apt install -y \
	build-essential \
	curl \
	gcc \
	libreadline-dev \
	make \
	--no-install-recommends

ARG VERSION=5.0
WORKDIR /data
RUN curl -#L "https://ftp.gnu.org/gnu/bash/bash-${VERSION}.tar.gz" \
	| tar --strip=1 -xz

ARG PREFIX=/opt
ARG BUILD=./build.dir
RUN true \
	&& mkdir -p "${BUILD}" \
	&& cd "${BUILD}" \
	&& ../configure \
		--enable-alias                      \
		--enable-arith-for-command          \
		--enable-array-variables            \
		--enable-bang-history               \
		--enable-brace-expansion            \
		--enable-casemod-attributes         \
		--enable-casemod-expansions         \
		--enable-command-timing             \
		--enable-cond-command               \
		--enable-cond-regexp                \
		--enable-coprocesses                \
		--enable-debugger                   \
		--enable-dev-fd-stat-broken         \
		--enable-directory-stack            \
		--enable-direxpand-default          \
		--enable-disabled-builtins          \
		--enable-dparen-arithmetic          \
		--enable-extended-glob              \
		--enable-extended-glob-default      \
		--enable-function-import            \
		--enable-glob-asciiranges-default   \
		--enable-help-builtin               \
		--enable-history                    \
		--enable-job-control                \
		--enable-mem-scramble               \
		--enable-multibyte                  \
		--enable-net-redirections           \
		--enable-process-substitution       \
		--enable-profiling                  \
		--enable-progcomp                   \
		--enable-prompt-string-decoding     \
		--enable-readline                   \
		--enable-restricted                 \
		--enable-select                     \
		--enable-separate-helpfiles         \
		--enable-single-help-strings        \
		--enable-static-link                \
		--enable-strict-posix-default       \
		--enable-usg-echo-default           \
		--enable-xpg-echo-default           \
		--prefix="${PREFIX}"

RUN make -C "${BUILD}" -j$(nproc) all install

FROM ${BASE} AS runtime
COPY --from=build /opt /opt
ENTRYPOINT [ "/opt/bin/bash" ]
CMD        [ "-l" ]
