#!/usr/bin/env -S docker build --compress -t pvtmert/steamcmd:csgo -f

ARG APPID=740

FROM pvtmert/steamcmd

ARG APPID
RUN steamcmd \
	+login anonymous \
	+force_install_dir "${GAME}" \
	+app_update "${APPID}" \
	+quit

ENV PORT 27015
EXPOSE ${PORT}/tcp ${PORT}/udp

RUN ( \
	echo sv_cheats 1; \
	echo sv_infinite_ammo 1; \
	echo cl_grenadepreview 1; \
	echo ammo_grenade_limit_total 5; \
	echo mp_freezetime 0; \
	echo mp_roundtime 60; \
	echo mp_roundtime_defuse 60; \
	echo sv_grenade_trajectory 1; \
	echo sv_grenade_trajectory_time 10; \
	echo sv_showimpacts 1; \
	echo mp_limitteams 0; \
	echo mp_autoteambalance 0; \
	echo mp_maxmoney 60000; \
	echo mp_startmoney 60000; \
	echo mp_buytime 9999; \
	echo mp_buy_anywhere 1; \
	echo mp_restartgame 1; \
	echo bot_zombie 0; \
	echo bot_stop 0; \
	echo bot_kick; \
	echo bot_add_t; \
	echo bot_add_ct; \
	echo bot_place; \
	echo bot_difficulty 2; \
	echo bot_difficulty 3; \
	echo ai_drawbattlelines 1; \
	echo mp_drop_knife_enable 1; \
	echo bot_join_after_player 0; \
	echo sv_hibernate_when_empty 0; \
	echo bot_defer_to_human_goals 0; \
	echo bot_defer_to_human_items 0; \
	) | tee /home/csgo/cfg/server.cfg

ENV AUTHCODE ""
ENV PASSWORD ""
ENV RCONPASS ""
ENV TAGS ""

ENV APPID=$APPID
CMD srcds_run \
	-console \
	-usercon \
	+game csgo \
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
