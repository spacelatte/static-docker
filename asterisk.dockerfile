#!/usr/bin/env -S docker build --compress -t pvtmert/asterisk -f

FROM debian:stable

RUN apt update
RUN apt install -y \
	asterisk

WORKDIR /etc/asterisk

RUN ( \
	echo "[common](!)"          ; \
	echo "type=friend"          ; \
	echo "host=dynamic"         ; \
	echo "dtmfmode=rfc2833"     ; \
	echo "context=internal"     ; \
	echo "[5396054246](common)" ; \
	echo "secret=mert"          ; \
	echo "[5318666766](common)" ; \
	echo "secret=sahin"         ; \
	echo "[5357169129](common)" ; \
	echo "secret=ata"           ; \
	echo "[trunk]"              ; \
	echo "type=friend"          ; \
	echo "context=internal"     ; \
	echo "host=localhost"       ; \
	echo "dtmfmode=rfc2833"     ; \
	) | tee -a ./sip.conf

RUN ( \
	echo "[internal]"                                            ; \
	echo "exten => _XXXX,1,Dial(SIP/\${EXTEN:0:4},90)"           ; \
	echo "exten => _5XXXXXXXXX,1,Dial(SIP/\${EXTEN:0:10},90)"    ; \
	echo "exten => _05XXXXXXXXX,1,Dial(SIP/\${EXTEN:1:11},90)"   ; \
	echo "exten => _905XXXXXXXXX,1,Dial(SIP/\${EXTEN:2:12},90)"  ; \
	echo "exten => _.905XXXXXXXXX,1,Dial(SIP/\${EXTEN:3:13},90)" ; \
	) | tee -a ./extensions.conf

CMD true \
	&& service asterisk start \
	&& until pidof asterisk; do printf .; done \
	&& echo \
	&& sleep 1 \
	&& tail -fn99 \
	/var/log/asterisk/messages \
	/var/log/asterisk/queue_log \
	/var/log/asterisk/cdr-csv/Master.csv

EXPOSE 5060/tcp 5060/udp
