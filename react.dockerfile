#!/usr/bin/env docker build --compress -t pvtmert/react -f

FROM alpine

WORKDIR /data

RUN apk add --no-cache npm

RUN npm install -g   \
	yarn             \
	create-react-app \
	react-native-cli \
	firebase-tools   \
	flow-bin         \
	detox-cli

