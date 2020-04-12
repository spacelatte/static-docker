#!/usr/bin/env -S docker build --no-cache --compress -t pvtmert/ipsec -f

FROM debian:9

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y \
	iptables \
	racoon \
	procps \
	kmod \
	man

WORKDIR /etc/racoon

# see: https://www.daemon-systems.org/man/racoon.conf.5.html
RUN ( \
	echo "complex_bundle on;"          ; \
	echo "remote anonymous {"          ; \
	echo "  exchange_mode"             ; \
	echo "    main, aggressive;"       ; \
	echo "  #my_identifier"            ; \
	echo "  #  address 192.168.99.10;" ; \
	echo "  generate_policy unique;"   ; \
	echo "  nat_traversal on;"         ; \
	echo "  passive on;"               ; \
	echo "  proposal {"                ; \
	echo "    authentication_method"   ; \
	echo "      xauth_psk_server;"     ; \
	echo "    encryption_algorithm"    ; \
	echo "      aes256;"               ; \
	echo "    hash_algorithm md5;"     ; \
	echo "    # md5, sha1, sha256"     ; \
	echo "    dh_group 2;"             ; \
	echo "  }"                         ; \
	echo "}"                           ; \
	echo "sainfo anonymous {"          ; \
	echo "  lifetime time 1 hour;"     ; \
	echo "  compression_algorithm"     ; \
	echo "    deflate;"                ; \
	echo "  encryption_algorithm aes;" ; \
	echo "  authentication_algorithm"  ; \
	echo "    #non_auth"               ; \
	echo "    hmac_md5,"               ; \
	echo "    hmac_sha1;"              ; \
	echo "    #hmac_sha256"            ; \
	echo "    #hmac_sha256_128"        ; \
	echo "}"                           ; \
	echo "mode_cfg {"                  ; \
	echo "  save_passwd on;"           ; \
	echo "  auth_source pam;"          ; \
	echo "  banner \"/etc/motd\";"     ; \
	echo "  pool_size 64;"             ; \
	echo "  dns4 0.0.0.0;"             ; \
	echo "  dns4 1.1.1.1;"             ; \
	echo "  dns4 8.8.8.8;"             ; \
	echo "  #dns4 208.67.222.222;"     ; \
	echo "  network4 192.168.99.11;"   ; \
	echo "  #netmask4 255.255.255.0;"  ; \
	echo "}"                           ; \
) | tee -a racoon.conf
#COPY mert2.conf racoon.conf
RUN mkdir --mode=0777 -p /var/run/racoon
ENV PSK   "randompsk"
ENV PASS  "userpass0"
ENV USER  "vpn"
ENV GROUP "users"
EXPOSE 500/udp 4500/udp
CMD ( \
	useradd -MNro \
		-s "/bin/true" \
		-u "${UID:-9999}" \
		-g "${GROUP}" \
		-d "/home" \
		"${USER}"; \
	passwd -du "${USER}"; \
	echo "${USER}:${PASS}" | chpasswd; \
	echo "*\t${PSK}" | tee -a psk.txt; \
	iptables -v -t nat -A POSTROUTING -j MASQUERADE -o eth0; \
	sysctl -w net.ipv4.ip_forward=1; \
	man racoon.conf | cat; \
	modprobe af_key; \
	racoon -4LFCddv || ( \
		export CODE=$?; \
		cat -n racoon.conf; \
		exit $((CODE)); \
	); \
)
