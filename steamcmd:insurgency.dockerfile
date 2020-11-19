#!/usr/bin/env -S docker build --compress -t pvtmert/steamcmd:insurgency -f

ARG APPID=237410

FROM pvtmert/steamcmd

ARG APPID
RUN steamcmd \
	+login anonymous \
	+force_install_dir "${GAME}" \
	+app_update "${APPID}" \
	+quit

ENV PORT 27015
EXPOSE ${PORT}/tcp ${PORT}/udp

ENV APPID=$APPID
CMD srcds_run \
	-console \
	+game insurgency \
	+hostname "${HOSTNAME}" \
	+port "${PORT}" \
	+map station \
