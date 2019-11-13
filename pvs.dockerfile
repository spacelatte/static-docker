#!/usr/bin/env -S docker build --compress -t pvtmert/pvs -f

FROM gcc:7

# INSTALL DEPENDENCIES
RUN apt update -yq \
	&& apt install -yq --no-install-recommends wget \
	&& apt clean -yq

# INSTALL PVS-Studio
RUN wget -q -O - https://files.viva64.com/etc/pubkey.txt | apt-key add - \
	&& wget -O /etc/apt/sources.list.d/viva64.list \
	https://files.viva64.com/etc/viva64.list \
	&& apt update -yq \
	&& apt install -yq pvs-studio strace \
	&& pvs-studio --version \
	&& apt clean -yq
