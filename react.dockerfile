#!/usr/bin/env -S docker build --compress -t pvtmert/react -f

FROM alpine

RUN apk add --no-cache npm

RUN npm install -g   \
	create-react-app \
	detox-cli        \
	firebase-tools   \
	flow-bin         \
	react-native-cli \
	yarn             \
	--no-optional

WORKDIR /data
