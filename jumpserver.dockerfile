#!/usr/bin/env -S docker -H ssh://screw.direct build --compress -t pvtmert/jumpserver -f

FROM debian:10

RUN apt update
RUN apt install -y \
	curl nginx openssl openssh-client

RUN ( \
	echo "Host *.ssh" ; \
	echo "  ProxyCommand openssl s_client -quiet -servername %h -connect 0:443" ; \
	) | tee -a /etc/ssh/ssh_config

ARG CERT_FILE=ssl
ARG CERT_HOST=jumpserver
ARG CERT_DAYS=3650
ARG CERT_SIZE=4096
RUN openssl req \
	-new        \
	-x509       \
	-sha256     \
	-nodes      \
	-newkey "rsa:${CERT_SIZE}" \
	-keyout "${CERT_FILE}.key" \
	-out    "${CERT_FILE}.crt" \
	-days   "${CERT_DAYS}" \
	-subj   "/CN=${CERT_HOST}"

RUN rm /etc/nginx/sites-enabled/default && ( \
		echo "server {"                           ; \
		echo "  listen 80;"                       ; \
		echo "  set \$path \$request_uri;"        ; \
		echo "  return 307 https://\$host\$path;" ; \
		echo "}"                                  ; \
		echo "server {"                           ; \
		echo "  listen unix:/run/nginx.sock;"     ; \
		echo "  root /var/www/html;"              ; \
		echo "  index index.html;"                ; \
		echo "}"                                  ; \
	) | tee -a /etc/nginx/sites-enabled/default

RUN mkdir -p /etc/nginx/streams-enabled \
	&& ( \
		echo "stream {"                                ; \
		echo "  include /etc/nginx/streams-enabled/*;" ; \
		echo "}"                                       ; \
	) | tee -a /etc/nginx/nginx.conf \
	&& ( \
		echo "' \$remote_addr'             " ; \
		echo "' [\$time_local]'            " ; \
		echo "' \$protocol'                " ; \
		echo "' \$status'                  " ; \
		echo "' \$bytes_sent'              " ; \
		echo "' \$bytes_received'          " ; \
		echo "' \$session_time'            " ; \
		echo "' \$upstream_addr'           " ; \
		echo "' \$upstream_bytes_sent'     " ; \
		echo "' \$upstream_bytes_received' " ; \
		echo "' \$upstream_connect_time'   " ; \
	) | ( \
		echo "log_format stream $(cat);"                     ; \
		echo "access_log /var/log/nginx/stream.log stream;"  ; \
		echo "tcp_nodelay on;"                               ; \
		echo "resolver 8.8.8.8;"                             ; \
		echo "resolver_timeout 5s;"                          ; \
		echo "map \$ssl_server_name \$name {"                ; \
		echo "  ~(.+)\.ssh \$1:22;"                          ; \
		echo "  default unix:/run/nginx.sock;"               ; \
		echo "}"                                             ; \
		echo "server {"                                      ; \
		echo "  listen 443 ssl;"                             ; \
		echo "  ssl_certificate     /${CERT_FILE}.crt;"      ; \
		echo "  ssl_certificate_key /${CERT_FILE}.key;"      ; \
		echo "  ssl_preread on;"                             ; \
		echo "  proxy_ssl off;"                              ; \
		echo "  proxy_pass \$name;"                          ; \
		echo "}"                                             ; \
	) | tee -a /etc/nginx/streams-enabled/default

RUN mv /var/www/html/index.nginx-debian.html /var/www/html/index.html

EXPOSE 443
RUN nginx -t
RUN ln -sf /dev/stdout /var/log/nginx/stream.log
CMD nginx -g 'daemon off;'
