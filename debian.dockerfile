#!/usr/bin/env -S docker build --compress -t pvtmert/debian -f

FROM debian:stable

RUN apt update
RUN apt install -y \
	man \
	git \
	vim \
	tmux \
	ncdu \
	nano \
	less \
	nmap \
	cron \
	tree \
	htop \
	iftop \
	iotop \
	nginx \
	sshfs \
	cmake \
	clang \
	nodejs \
	bcrypt \
	ccrypt \
	airspy \
	procps \
	x11vnc \
	python3 \
	tcpdump \
	php-fpm \
	locales \
	hfsplus \
	binwalk \
	dnsmasq \
	testdisk \
	automake \
	autoconf \
	dfu-util \
	bsdutils \
	binutils \
	dnsutils \
	elfutils \
	hfsutils \
	hfsprogs \
	net-tools \
	diffutils \
	dateutils \
	coreutils \
	cronutils \
	mailutils \
	moreutils \
	findutils \
	cloud-init \
	vnc4server \
	pkg-config \
	cifs-utils \
	subversion \
	exfat-fuse \
	debianutils \
	exfat-utils \
	aircrack-ng \
	avahi-utils \
	avahi-daemon \
	bsdmainutils \
	clang-format \
	airport-utils \
	avahi-autoipd \
	squashfs-tools \
	avahi-discover \
	suckless-tools \
	bash-completion \
	build-essential \
	default-jdk-headless \
	&& apt clean \
	&& apt autoclean \
	&& apt autoremove \
	&& echo done

RUN echo "en_US.UTF-8 UTF-8" \
	| tee -a /etc/locale.gen \
	&& locale-gen

WORKDIR /tmp
ENV USER root
CMD login -f $USER || su - $USER
