#!/usr/bin/env -S docker build --compress -t pvtmert/esp-idf -f

FROM debian

RUN apt update
RUN apt install -y \
	curl gcc git wget make flex bison gperf libncurses-dev \
	python python-pip python-future python-setuptools python-serial \
	python-cryptography python-pyparsing python-pyelftools

WORKDIR /data

ENV IDF_PATH ${PWD}/esp-idf
ENV REPO https://github.com/espressif/esp-idf.git
ENV PATH $PATH:xtensa-esp32-elf/bin
ENV URL https://dl.espressif.com/dl/xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz

RUN curl -#L "${URL}" | tar -zx

RUN git clone --recursive "${REPO}" "${IDF_PATH}" && \
	python -m pip install --user -r "${IDF_PATH}/requirements.txt"
