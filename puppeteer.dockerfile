#!/usr/bin/env -S docker build --compress -t pvtmert/puppeteer -f

FROM centos:7

RUN yum update -y && yum install -y \
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
	git curl xz

ENV NODE_VER 10.15.3

RUN curl -#L "https://nodejs.org/dist/v${NODE_VER}/node-v${NODE_VER}-linux-x64.tar.xz" \
	| xz -vvdc | tar --strip-components=1 -xC /usr/local

RUN npm install -g --unsafe-perm=true puppeteer

WORKDIR /data
