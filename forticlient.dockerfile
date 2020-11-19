#!/usr/bin/env -S docker build --compress -t pvtmert/forticlient -f

FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt install -y \
	curl gnupg nano xterm \
	tasksel debconf-utils

RUN debconf-set-selections <<EOF\n\
keyboard-configuration	keyboard-configuration/compose	select	No compose key\n\
keyboard-configuration	keyboard-configuration/switch	select	No temporary switch\n\
keyboard-configuration	keyboard-configuration/store_defaults_in_debconf_db	boolean	true\n\
keyboard-configuration	keyboard-configuration/unsupported_config_options	boolean	true\n\
keyboard-configuration	keyboard-configuration/altgr	select	The default for the keyboard layout\n\
keyboard-configuration	keyboard-configuration/xkb-keymap	select	us\n\
keyboard-configuration	keyboard-configuration/model	select	Generic 105-key PC \(intl.\)\n\
keyboard-configuration	keyboard-configuration/modelcode	string	pc105\n\
keyboard-configuration	keyboard-configuration/optionscode	string	terminate:ctrl_alt_bksp\n\
keyboard-configuration	keyboard-configuration/layoutcode	string	us\n\
keyboard-configuration	keyboard-configuration/toggle	select	No toggling\n\
keyboard-configuration	keyboard-configuration/unsupported_options	boolean	true\n\
keyboard-configuration	keyboard-configuration/layout	select\n\
keyboard-configuration	keyboard-configuration/variant	select	English \(US\)\n\
keyboard-configuration	keyboard-configuration/unsupported_layout	boolean	true\n\
keyboard-configuration	keyboard-configuration/unsupported_config_layout	boolean	true\n\
keyboard-configuration	keyboard-configuration/variantcode	string\n\
keyboard-configuration	keyboard-configuration/ctrl_alt_bksp	boolean	true\n\
EOF\n

#ARG PREFIX="task-"
ARG TASK="ubuntu-desktop"
#RUN tasksel --list-tasks; apt search $TASK; false
RUN apt install -y "${PREFIX}${TASK}" \
	|| tasksel install      "${TASK}"

RUN curl -s "https://repo.fortinet.com/repo/ubuntu/DEB-GPG-KEY" | apt-key add -
RUN echo "deb [arch=amd64] https://repo.fortinet.com/repo/ubuntu bionic multiverse" \
	| tee /etc/apt/sources.list.d/forticlient.list
RUN apt update
RUN apt install -y forticlient

RUN apt install -y vino
WORKDIR /root
ARG PASS=000000
#RUN printf "%s\n%s\n" "${PASS}" "${PASS}" | vncpasswd
CMD vncserver \
	:0 \
	-fg \
	-useold \
	-verbose \
	-depth 16 \
	-localhost no \
	-name $(hostname) \
	-geometry 1280x720 \
	-SecurityTypes None \
	--I-KNOW-THIS-IS-INSECURE \
	-- xterm
	#Plain,VncAuth
	#TLSNone,TLSVnc,TLSPlain
#CMD /bin/systemd
