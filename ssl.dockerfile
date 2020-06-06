#!/usr/bin/env -S docker build --compress -t pvtmert/ssl -f

FROM nginx:latest

RUN apt update
RUN apt install -y openssl

WORKDIR /srv
ARG CERT_HOST=localhost
ARG CERT_DAYS=3650
ARG CERT_SIZE=4096
RUN openssl req \
  -new        \
  -x509       \
  -sha256     \
  -nodes      \
  -newkey "rsa:${CERT_SIZE}" \
  -keyout "${CERT_HOST}.key" \
  -out    "${CERT_HOST}.crt" \
  -subj   "/CN=${CERT_HOST}" \
  -days   "${CERT_DAYS}"

RUN rm  -f /etc/nginx/conf.d/default.conf
RUN echo "\n\
resolver       \n\
  192.168.65.1 \n\
  127.0.0.11   \n\
  127.0.0.1    \n\
  valid=30s ipv6=off;             \n\
ssl_certificate                   \n\
  $(realpath "${CERT_HOST}").crt; \n\
ssl_certificate_key               \n\
  $(realpath "${CERT_HOST}").key; \n\
server {\n\
  listen  80 default_server;      \n\
  return 301 https://\$host\$uri; \n\
}\n\
map \$host \$target {\n\
  ~^(?<sub>.+)\.localhost$ \${sub}; \n\
  default %HOST%:%PORT%; \n\
  volatile;              \n\
}\n\
server {\n\
  ssl_certificate     /\$hostname.ssl;\n\
  ssl_certificate_key /\$hostname.ssl;\n\
  #ssl_certificate     $(pwd)/\$ssl_server_name.crt; \n\
  #ssl_certificate_key $(pwd)/\$ssl_server_name.key; \n\
  listen 443 ssl default_server; \n\
  add_header x-sub    \$sub    always;\n\
  add_header x-target \$target always;\n\
  set  \$p_url http://\$target ; \n\
  location / {\n\
    proxy_buffering         off; \n\
    proxy_read_timeout      10s; \n\
    proxy_send_timeout      10s; \n\
    proxy_connect_timeout   10s; \n\
    proxy_intercept_errors  on;  \n\
    proxy_request_buffering off; \n\
    proxy_set_header Host \$host;\n\
    proxy_redirect \$p_url /;    \n\
    proxy_pass     \$p_url  ;    \n\
  }\n\
}\n\
" | tee -a /etc/nginx/conf.d/default.conf
RUN chmod -R a+rX "$(pwd)"
RUN nginx -t || (cat /etc/nginx/conf.d/default.conf; exit 1)

ENV PORT 8080
ENV HOST host.docker.internal
CMD true; \
  find "$(pwd)" -type f -exec cat {} + >> "/$(hostname).ssl"; \
  sed -i "s:%PORT%:${PORT}:g" /etc/nginx/conf.d/default.conf; \
  sed -i "s:%HOST%:${HOST}:g" /etc/nginx/conf.d/default.conf; \
  cat /etc/nginx/conf.d/default.conf; \
  nginx -g 'daemon off;'
