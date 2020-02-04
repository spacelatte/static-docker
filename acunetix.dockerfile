#!/usr/bin/env -S docker build --compress -t pvtmert/acunetix -f

FROM debian:stable

RUN apt update
RUN apt install -y \
	libxtst6       \
	libxdamage1    \
	libgtk-3-0     \
	libasound2     \
	libnss3        \
	libxss1        \
	libx11-xcb1    \
	sudo curl bzip2

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
