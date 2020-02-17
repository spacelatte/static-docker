#!/usr/bin/env -S docker build --compress -t pvtmert/nginx -f

ARG VERSION=1.17.8
ARG PREFIX=/nginx
ARG BASE=debian:latest
# you may use 'centos:7' or 'debian:stable' atm

FROM ${BASE} as build
ARG BASE

#FROM centos:7 as build
RUN echo "${BASE}" | grep -qi "centos" \
	&& yum install -y \
		git \
		gcc \
		gcc-c++ \
		make \
		perl \
		libatomic \
		pcre-devel \
		openssl-devel \
		libxml2-devel \
		libxslt-devel \
		gd-devel \
		zlib-devel \
		geoip-devel \
		gperftools-devel \
		libatomic_ops-devel \
	|| true

#FROM debian:stable as build
RUN echo "${BASE}" | grep -qi "debian" \
	&& apt update \
	&& apt install -y \
		build-essential \
		libgoogle-perftools-dev \
		libatomic-ops-dev \
		libpcre++-dev \
		libpcre2-dev \
		libgeoip-dev \
		libxslt1-dev \
		libxml2-dev \
		libssl-dev \
		zlib1g-dev \
		libatomic1 \
		libgd-dev \
		curl \
		perl \
		git \
	|| true

ARG VERSION
WORKDIR /data
RUN curl -#L "https://nginx.org/download/nginx-${VERSION}.tar.gz" \
	| tar --strip=1 -xzC .

ARG ZLIB=zlib.src
RUN mkdir -p "${ZLIB}"
RUN curl -#L "http://zlib.net/zlib-1.2.11.tar.gz" \
	| tar --strip=1 -xzC "${ZLIB}"

ARG PCRE=pcre.src
RUN mkdir "${PCRE}"
RUN curl -#L "https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz" \
	| tar --strip=1 -xzC "${PCRE}"

RUN git clone --depth=1 \
	"https://github.com/wdaike/ngx_upstream_jdomain.git" \
	"ngx_upstream_jdomain"

RUN git clone --depth=1 \
	"https://github.com/cep21/healthcheck_nginx_upstreams.git" \
	"healthcheck_nginx_upstreams"

RUN git clone --depth=1 \
	"https://github.com/yaoweibin/nginx_upstream_check_module.git" \
	"nginx_upstream_check_module"

ARG PREFIX
RUN ( ./configure \
		--prefix="${PREFIX}" \
		--with-cc-opt=" "    \
		--with-ld-opt=" "    \
		--with-select_module                    \
		--with-poll_module                      \
		--with-threads                          \
		--with-file-aio                         \
		--with-http_ssl_module                  \
		--with-http_v2_module                   \
		--with-http_realip_module               \
		--with-http_addition_module             \
		--with-http_xslt_module                 \
		--with-http_xslt_module=dynamic         \
		--with-http_image_filter_module         \
		--with-http_image_filter_module=dynamic \
		--with-http_geoip_module                \
		--with-http_geoip_module=dynamic        \
		--with-http_sub_module                  \
		--with-http_dav_module                  \
		--with-http_flv_module                  \
		--with-http_mp4_module                  \
		--with-http_gunzip_module               \
		--with-http_gzip_static_module          \
		--with-http_auth_request_module         \
		--with-http_random_index_module         \
		--with-http_secure_link_module          \
		--with-http_degradation_module          \
		--with-http_slice_module                \
		--with-http_stub_status_module          \
		--with-mail                             \
		--with-mail=dynamic                     \
		--with-mail_ssl_module                  \
		--with-stream                           \
		--with-stream=dynamic                   \
		--with-stream_ssl_module                \
		--with-stream_realip_module             \
		--with-stream_geoip_module              \
		--with-stream_geoip_module=dynamic      \
		--with-stream_ssl_preread_module        \
		--with-google_perftools_module          \
		--with-cpp_test_module                  \
		--with-compat                           \
		--with-pcre                             \
		--with-pcre="${PCRE}"                   \
		--with-pcre-jit                         \
		--with-libatomic                        \
		--with-debug                            \
		--with-zlib="${ZLIB}"                   \
		--add-module="nginx_upstream_check_module" \
	)

#&& mkdir -p ./build \
#&& cd ./build       \
#&& cp -r ../auto ./ \
#--with-openssl                          \
#--with-http_perl_module                 \
#--with-http_perl_module=dynamic         \

RUN make \
	-C . \
	-j 1 \
	build install

FROM ${BASE}
ARG BASE

#FROM centos:7
RUN echo "${BASE}" | grep -qi centos \
	&& yum install -y \
		gperftools-libs \
		openssl \
		pcre \
	|| true

#FROM debian:stable
RUN echo "${BASE}" | grep -qi debian \
	&& apt update \
	&& apt install -y \
		libgoogle-perftools4 \
		libssl1.1 \
		openssl \
	|| true

ARG PREFIX
WORKDIR "${PREFIX}"
COPY --from=build "${PREFIX}" ./
RUN ln -sf /dev/stderr "${PREFIX}/logs/error.log"
RUN ln -sf /dev/stdout "${PREFIX}/logs/access.log"
RUN ./sbin/nginx -t
CMD ./sbin/nginx -g 'daemon off;'

ARG CERT_FILE=/ssl
ARG CERT_HOST=localhost
ARG CERT_DAYS=3650
ARG CERT_SIZE=4096
RUN openssl req \
	-new        \
	-x509       \
	-sha256     \
	-nodes      \
	-newkey "rsa:${CERT_SIZE}" \
	-keyout "${CERT_FILE}.key" \
	-out    "${CERT_FILE}.crt" \
	-days   "${CERT_DAYS}"     \
	-subj   "/CN=${CERT_HOST}"
