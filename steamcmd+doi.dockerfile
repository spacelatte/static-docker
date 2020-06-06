#!/usr/bin/env -S docker build --compress -t pvtmert/steamcmd:doi -f

ARG APPID=462310

FROM pvtmert/steamcmd

ARG APPID
RUN steamcmd \
	+login anonymous \
	+force_install_dir "${GAME}" \
	+app_update "${APPID}" \
	+quit

ENV PORT 27015

EXPOSE ${PORT}/tcp ${PORT}/udp

ENTRYPOINT /home/srcds_run

CMD /home/srcds_run \
	-console \
	+game doi \
	+port ${PORT} \
	+hostname ${HOSTNAME} \
	+map "crete entrenchment" \
