#!/usr/bin/env -S docker build --compress -t pvtmert/ssh-gateway -f

FROM debian:stable

RUN apt update
RUN apt install -y \
	openssh-server \
	busybox-static \
	nginx

RUN ln -sf /dev/stdout "/var/log/nginx/access.log"
RUN ln -sf /dev/stderr "/var/log/nginx/error.log"

RUN mkdir      /run/sshd
RUN chmod 0755 /run/sshd

RUN sed -i 's:^UsePAM yes:UsePAM no:g' \
	/etc/ssh/sshd_config

ARG HEADER=hosgeldiniz
ARG USER=jump
ARG GROUP=users
ARG WORKDIR=/data

WORKDIR "${WORKDIR}"
#RUN chmod -R 0750 .
#RUN chgrp -R "${GROUP}" .
#RUN ln -s /bin ./bin
#RUN ln -s /dev ./dev
#RUN ln -s /tmp ./tmp
RUN mkdir -p bin && cp \
	"$(which busybox)" \
	"bin/busybox"
RUN busybox --install -s bin

RUN ssh-keygen -t rsa -f ssh_host_rsa_key
#ADD https://storage.googleapis.com/serveo/download/2018-05-08/serveo-linux-amd64 \
#	./bin/serveo
COPY ./serveo ./bin/serveo
RUN chmod +x ./bin/serveo

RUN ( \
	echo "UseDNS no"            ; \
	echo "PrintMotd yes"        ; \
	echo "PrintLastLog yes"     ; \
	echo "Banner /etc/motd"     ; \
	echo "AllowUsers ${USER}"   ; \
	echo "AllowGroups ${GROUP}" ; \
	echo "TCPKeepAlive yes"     ; \
	echo "VersionAddendum ${HEADER}"  ; \
	echo "ChrootDirectory ${WORKDIR}" ; \
	echo "AuthenticationMethods none" ; \
	echo "PasswordAuthentication yes" ; \
	echo "PermitEmptyPasswords   yes" ; \
	echo "ClientAliveCountMax 9"      ; \
	echo "ClientAliveInterval 11"     ; \
	echo "Match User *,${USER},!root,!admin"; \
	echo "  PermitTTY yes"                  ; \
	echo "  PermitTunnel yes"               ; \
	echo "  X11Forwarding yes"              ; \
	echo "  AllowTcpForwarding yes"         ; \
	echo "  AllowAgentForwarding yes"       ; \
	echo "  AllowStreamLocalForwarding yes" ; \
	echo "  GatewayPorts clientspecified"   ; \
	echo "  #ForceCommand cat -"             ; \
	) | tee -a /etc/ssh/sshd_config

RUN useradd -MNro \
	-s "/usr/sbin/nologin" \
	-u "${UID:-999}" \
	-g "${GROUP}" \
	-s "/bin/sh" \
	-d "$(pwd)" \
	"${USER}"
RUN passwd -du "${USER}"
RUN mkdir --mode=0777 -vp tmp
CMD true \
	&& : mkdir -p bin dev tmp lib lib64 \
	&& : mount --bind /bin bin \
	&& : mount --bind /dev dev \
	&& : mount --bind /tmp tmp \
	&& : mount --bind /lib lib \
	&& : mount --bind /lib64 lib64 \
	&& ls -lha . \
	& : nginx -g 'daemon off;' \
	& : $(which sshd) -4De \
	& ./bin/serveo \
		-disable_telemetry \
		-domain "${DOMAIN:-$(hostname)}" \
	& wait
