#!/usr/bin/env -S docker build --compress -t pvtmert/steamcmd:hl2dm -f

ARG APPID=232370

FROM pvtmert/steamcmd

ARG APPID
RUN steamcmd \
	+login anonymous \
	+force_install_dir "${GAME}" \
	+app_update "${APPID}" \
	+quit

ENV PORT 27015
EXPOSE ${PORT}/tcp ${PORT}/udp

ENV AUTHCODE ""
ENV PASSWORD ""
ENV RCONPASS ""
ENV TAGS "docker,solo,gg"

ENV APPID=$APPID
CMD srcds_run \
	-console \
	-usercon \
	+game hl2dm \
	+port "${PORT}" \
	+hostname "${HOSTNAME}" \
	+sv_password "${PASSWORD}" \
	+sv_setsteamaccount "${AUTHCODE}" \
	+rcon_password "${RCONPASS}" \
	+mapgroup mg_active \
	+sv_tags "${TAGS}" \
	+game_type 0 \
	+game_mode 1 \
	+map de_dust2 \
