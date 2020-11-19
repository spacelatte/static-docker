#!/usr/bin/env -S docker build --compress -t pvtmert/proxysql -f

ARG VERSION=2.0.12
ARG BASE=centos:7

FROM ${BASE}

RUN yum install -y \
	gnutls perl perl-DBD-MySQL

ARG BASE
ARG VERSION
ARG BASEURL="https://github.com/sysown/proxysql/releases/download"
ARG STANZA="v${VERSION}/proxysql-${VERSION}-1-\${BASE//[:.]/}.$(uname -m).rpm"

RUN eval rpm -ivh "${BASEURL}/${STANZA}"
