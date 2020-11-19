#!/usr/bin/env -S docker build --compress -t pvtmert/puppeteer -f

ARG NODE_VER=10.15.3
ARG VERSION=3.1.0
FROM centos:7

RUN yum install -y \
	pango                    \
	libXcomposite            \
	libXcursor               \
	libXdamage               \
	libXext                  \
	libXi                    \
	libXtst                  \
	cups-libs                \
	libXScrnSaver            \
	libXrandr                \
	GConf2                   \
	alsa-lib                 \
	atk                      \
	gtk3                     \
	ipa-gothic-fonts         \
	xorg-x11-fonts-100dpi    \
	xorg-x11-fonts-75dpi     \
	xorg-x11-utils           \
	xorg-x11-fonts-cyrillic  \
	xorg-x11-fonts-Type1     \
	xorg-x11-fonts-misc      \
	git curl


ARG NODE_VER
RUN curl --compressed -#L "https://nodejs.org/dist/v${NODE_VER}/node-v${NODE_VER}-linux-x64.tar.gz" \
	| tar --strip=1 -xzC /usr/local

ARG VERSION
RUN npm install -g --allow-root --unsafe-perm=true puppeteer@${VERSION}

WORKDIR /data
