#!/usr/bin/env -S docker build --compress -t pvtmert/arduino -f

FROM debian:10

RUN apt update
RUN apt install -y \
	xvfb arduino curl python \
	python-pip python-serial

WORKDIR /data

ARG VERSION=0.6.0
RUN mkdir -p /usr/local/bin
RUN curl -#Lk "https://github.com/arduino/arduino-cli/releases/download/${VERSION}/arduino-cli_${VERSION}_Linux_64bit.tar.gz" \
	| tar -xzC /usr/local/bin


RUN curl -skL https://github.com/arduino/Arduino/wiki/Unofficial-list-of-3rd-party-boards-support-urls \
	| grep -oE '"http[^"]+\.json"' \
	| tr -d '"' \
	| xargs -n1 -P$(nproc) -I% -- bash -c 'curl -Ifsm1 "%" | grep -qi "application/json" && echo "%"' \
	| sort -u \
	| grep -vi \
		-e rfduino.com \
		-e zoubworld.com \
		-e www.dwengo.org \
		-e package_redbear_index.json \
	| tee /urls.txt
#	| tr -s \\n , \

RUN echo "https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json" \
	| tee -a /urls.txt

RUN arduino-cli -v config init
RUN sed -i.old 's#board_manager: {}#board_manager:\n  additional_urls:#g' \
	~/.arduino15/arduino-cli.yaml
RUN sed 's:^:  - :g' /urls.txt \
	| tee -a ~/.arduino15/arduino-cli.yaml
RUN arduino-cli -v core update-index
RUN arduino-cli -v lib  update-index

RUN printf 'boardsmanager.additional.urls=%s\n' "$(cat /urls.txt | tr \\n ,)" \
	| tee "/prefs.txt"
#	| tee -a "~/.arduino15/preferences.txt" "/prefs.txt"

ENV BOARDS    "arduino:avr"
ENV LIBRARIES "SD TFT GSM Servo Keyboard Esplora Firmata LiquidCrystal Ethernet ArduinoBLE"

RUN ( \
		arduino-cli -v core install $BOARDS    ; \
		arduino-cli -v lib  install $LIBRARIES ; \
	)

ENV BOARD     "arduino:avr:uno"
CMD ( \
		arduino-cli -v core install $BOARDS    ; \
		arduino-cli -v lib  install $LIBRARIES ; \
		find . -iname libs.txt -exec cat {} + \
			| grep -viE '^http' \
			| tr \\n \\0 \
			| xargs -0 -- arduino-cli -v lib install ; \
		find . -iname libs.txt -exec cat {} + \
			| grep -iE '^http' \
			| tr \\n \\0 \
			| xargs -0 -n1 -I% -- bash -c 'curl -#Lk "%" | tar -xzC ~/Arduino/libraries'; \
		arduino-cli -v compile --fqbn $BOARD \
			--warnings default \
			$(dirname $(find . -iname "*.ino")) ; \
	)
