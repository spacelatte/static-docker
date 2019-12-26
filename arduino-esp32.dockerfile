#!/usr/bin/env -S docker build --compress -t pvtmert/arduino:esp32 -f

FROM pvtmert/arduino:latest

ENV BOARD     "esp32:esp32:esp32thing:PartitionScheme=min_spiffs"
ENV BOARDS    "esp32:esp32"
ENV LIBRARIES "MQTT ArduinoJson"

RUN arduino-cli -v core install $BOARDS
RUN arduino-cli -v lib  install $LIBRARIES

#ENV PARAMS "build.partitions=min_spiffs"
