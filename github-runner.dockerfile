#!/usr/bin/env -S docker build --compress -t pvtmert/github-runner -f

ARG VERSION=2.283.2
FROM debian:stable

ARG DEBIAN_NONINTERACTIVE=yes
RUN apt update
RUN apt install -y \
	apt-transport-https \
	awscli \
	autoconf \
	automake \
	build-essential \
	clang \
	cmake \
	curl \
	default-mysql-client \
	default-jdk-headless \
	docker \
	docker.io \
	git \
	golang \
	jq \
	libicu-dev \
	libssl-dev \
	openssh-client \
	net-tools \
	nodejs \
	python3-dev \
	python3-pip \
	ssh \
	sudo \
	unzip \
	zip \
	zlib1g-dev \
	\
	airport-utils \
	avahi-utils \
	binutils \
	bsdmainutils \
	bsdutils \
	cifs-utils \
	coreutils \
	cronutils \
	dateutils \
	debianutils \
	diffutils \
	dnsutils \
	elfutils \
	exfat-utils \
	findutils \
	hfsutils \
	mailutils \
	moreutils \
	xz-utils \
	\
	--no-install-recommends \
	;

RUN curl -#LO https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb

RUN . /etc/os-release \
	&& curl -#LO https://packages.microsoft.com/config/debian/${VERSION_ID}/packages-microsoft-prod.deb \
	&& dpkg -i packages-microsoft-prod.deb \
	&& rm -vrf packages-microsoft-prod.deb

RUN apt update && apt install -y \
	aspnetcore-runtime-3.1 \
	dotnet-runtime-3.1 \
	dotnet-sdk-3.1 \
	./session-manager-plugin.deb

RUN ln -s ../local/bin/session-manager-plugin /usr/bin/session-manager-plugin

WORKDIR /home
ARG VERSION
RUN curl -#L https://github.com/actions/runner/releases/download/v${VERSION}/actions-runner-linux-x64-${VERSION}.tar.gz \
	| tar -xzC ./

RUN bash -x ./bin/installdependencies.sh

ENV PATH "$PATH:$PWD/bin:$PWD"
ENV RUNNER_ALLOW_RUNASROOT 1
ENV RUNNER_URL    "https://github.com/pvtmert/static-docker"
ENV RUNNER_NAME   "docker.$(hostname -f)"
ENV RUNNER_TOKEN  "$(curl -sX POST -H \"Authorization: token \${GITHUB_TOKEN}\" https://api.github.com/orgs/\${RUNNER_ORG}/actions/runners/registration-token | jq -r .token)"
ENV RUNNER_GROUP  "runnergroup"
ENV RUNNER_LABELS "docker,container"
ENV RUNNER_ORG    "pvtmert"

CMD set -eE; \
	trap 'bash -x /home/config.sh remove' HUP INT TERM; \
	eval ./config.sh --unattended --replace --ephemeral \
	--url    "${RUNNER_URL}" \
	--name   "${RUNNER_NAME}" \
	--token  "${RUNNER_TOKEN}" \
	--labels "${RUNNER_LABELS}" \
	&& (./run.sh --work "/home" || ./run.sh --work "/home";)
