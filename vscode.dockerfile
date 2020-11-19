#!/usr/bin/env -S docker build --compress -t pvtmert/vscode -f

FROM codercom/code-server:latest

USER root
WORKDIR /data

RUN apt update
RUN apt install -y \
	build-essential \
	iputils-ping \
	python3-pip \
	traceroute \
	docker.io \
	net-tools \
	hfsprogs \
	autoconf \
	automake \
	testdisk \
	dnsmasq \
	binwalk \
	tcpdump \
	python3 \
	locales \
	procps \
	golang \
	nodejs \
	iftop \
	iotop \
	sshfs \
	cmake \
	clang \
	lldb \
	ncdu \
	nasm \
	tree \
	curl \
	sudo \
	nano \
	htop \
	nmap \
	tmux \
	git \
	ssh \
	vim \
	man \
	gdb \
	bsdutils      \
	binutils      \
	dnsutils      \
	elfutils      \
	hfsutils      \
	diffutils     \
	dateutils     \
	coreutils     \
	cronutils     \
	mailutils     \
	moreutils     \
	findutils     \
	cifs-utils    \
	debianutils   \
	exfat-utils   \
	avahi-utils   \
	bsdmainutils  \
	airport-utils \
	squashfs-tools \
	default-jdk-headless \
	default-mysql-client \
	--no-install-recommends

RUN echo '\n\
vscjava.vscode-java-pack\n\
ms-azuretools.vscode-docker\n\
ms-python.python\n\
ms-vscode.cpptools\n\
ms-vscode.Go\n\
\n' | xargs -t -n1 -- code-server --force --install-extension \
|| echo failed successfully

ENV PASSWORD 1234
CMD [ "-vvv", "--disable-telemetry", "--bind-addr", "0.0.0.0:8000", "." ]
