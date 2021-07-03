#!/usr/bin/env -S docker build --compress -t pvtmert/acunetix -f

FROM debian:stable

RUN apt update
RUN apt install -y \
	bzip2       \
	curl        \
	libasound2  \
	libgtk-3-0  \
	libnss3     \
	libx11-xcb1 \
	libxdamage1 \
	libxss1     \
	libxtst6    \
	sudo        \
	--no-install-recommends

WORKDIR /home
RUN curl -#OL https://s3.amazonaws.com/a280ccaaf904330a389db759e6275285/acunetix_trial.sh

RUN ( \
		echo ""; \
		echo "q"; \
		echo "yes"; \
		echo "localhost"; \
		echo "root@local.domain"; \
		echo "Hello123!"; \
		echo "Hello123!"; \
	) | bash acunetix_trial.sh

CMD runuser -l acunetix -c /home/acunetix/.acunetix_trial/start.sh
EXPOSE 13443
