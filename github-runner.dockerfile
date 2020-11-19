#!/usr/bin/env -S docker build --compress -t pvtmert/github-runner -f

ARG VERSION=2.273.5
FROM debian:stable

RUN apt update
RUN apt install -y \
	apt-transport-https \
	liblttng-ust0 \
	libkrb5-3 \
	zlib1g \
	libssl1.1 \
	libicu63 \
	curl


RUN . /etc/os-release \
	&& curl -#LO https://packages.microsoft.com/config/debian/${VERSION_ID}/packages-microsoft-prod.deb \
	&& dpkg -i packages-microsoft-prod.deb \
	&& rm -vrf packages-microsoft-prod.deb

RUN apt update
RUN apt install -y \
	aspnetcore-runtime-3.1 \
	dotnet-runtime-3.1 \
	dotnet-sdk-3.1

WORKDIR /home
ARG VERSION
RUN curl -#L https://github.com/actions/runner/releases/download/v${VERSION}/actions-runner-linux-x64-${VERSION}.tar.gz \
	| tar -xzC ./

ENV PATH "$PATH:$PWD/bin:$PWD"
ENV RUNNER_ALLOW_RUNASROOT 1
ENV RUNNER_URL    "https://github.com/pvtmert/static-docker"
ENV RUNNER_NAME   "docker.$(hostname -f)"
ENV RUNNER_TOKEN  "ABL5CEQBSPKMM..."
ENV RUNNER_GROUP  "runnergroup"
ENV RUNNER_LABELS "docker,container"
CMD eval ./config.sh --unattended --replace \
	--url    "$RUNNER_URL" \
	--name   "$RUNNER_NAME" \
	--token  "$RUNNER_TOKEN" \
	--labels "$RUNNER_LABELS" \
	&& ./run.sh # --work "/tmp/runner"
