#!/usr/bin/env -S docker build --compress -t pvtmert/steamcmd:rust -f

ARG APPID=258550

FROM pvtmert/steamcmd

ARG APPID
RUN steamcmd \
	+login anonymous \
	+force_install_dir "${GAME}" \
	+app_update "${APPID}" \
	+quit

ENV PORT 28015
EXPOSE ${PORT}/tcp ${PORT}/udp

ENV APPID=$APPID
CMD /bin/bash
