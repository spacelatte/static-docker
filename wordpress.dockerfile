#!/usr/bin/env -S docker build --compress -t pvtmert/wordpress -f

#FROM centos:6

FROM debian:9

ARG MYSQL_USER=root
ARG MYSQL_PASS=password
ARG MYSQL_HOST=localhost
ARG MYSQL_PORT=3306
ARG MYSQL_NAME=wordpress

RUN echo mysql-server mysql-server/root_password       password "${MYSQL_PASS}" | debconf-set-selections
RUN echo mysql-server mysql-server/root_password_again password "${MYSQL_PASS}" | debconf-set-selections

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y \
	curl nginx php-fdomdocument \
	php-fpm php-mysql php-curl php-gd \
	ccze default-mysql-server

ARG VERSION=5.3
WORKDIR /data
RUN curl -#L https://wordpress.org/wordpress-${VERSION}.tar.gz \
	| tar --strip=1 -oxz

ARG PHP_VER=7.0
#ARG HOSTNAME=localhost
RUN rm /etc/nginx/sites-enabled/default && ( \
		echo "server_tokens off;"                                       ; \
		echo "error_log /tmp/log info;"                                 ; \
		echo "server {"                                                 ; \
		echo "  listen  80     default_server;"                         ; \
		echo "  listen 443 ssl default_server;"                         ; \
		echo "  index index.php index.html;"                            ; \
		echo "  autoindex on;"                                          ; \
		echo "  root /data;"                                            ; \
		echo "  location / {"                                           ; \
		echo "    try_files"                                            ; \
		echo "      \$uri"                                              ; \
		echo "      \$uri/"                                             ; \
		echo "      \$uri.html"                                         ; \
		echo "      #@extensionless-php"                                ; \
		echo "      #\$uri.php\$is_args\$args"                          ; \
		echo "      = /index.php\$is_args\$args"                        ; \
		echo "      #=404"                                              ; \
		echo "      ;"                                                  ; \
		echo "  }"                                                      ; \
		echo "  location ~ \.php$ {"                                    ; \
		echo "    #proxy_set_header Host \$hostname;"                   ; \
		echo "    #try_files \$uri = /index.php\$is_args\$args;"        ; \
		echo "    #include fastcgi_params;"                             ; \
		echo "    include snippets/fastcgi-php.conf;"                   ; \
		echo "    fastcgi_intercept_errors on;"                         ; \
		echo "    fastcgi_pass unix:/run/php/php${PHP_VER}-fpm.sock;"   ; \
		echo "  }"                                                      ; \
		echo "  location @extensionless-php {"                          ; \
		echo "    rewrite ^(.+)$ \$1.php last;"                         ; \
		echo "  }"                                                      ; \
		echo "}"                                                        ; \
	) | tee /etc/nginx/sites-enabled/wordpress

RUN nginx -t

#RUN echo "cgi.fix_pathinfo=0" | tee -a "/etc/php/${PHP_VER}/fpm/php.ini"

RUN ( \
		echo ""; \
		echo "[mysqld]"; \
		echo "#skip-grant-tables"; \
		echo "#default_authentication_plugin = mysql_native_password"; \
	) | tee -a /etc/mysql/conf.d/mysqld.cnf

RUN sed -i'' 's:127.0.0.1:0.0.0.0:g' $(grep -rl '127.0.0.1' /etc/mysql)
RUN sed -i'' "s:;clear_env = no:clear_env = no:g" \
	"/etc/php/${PHP_VER}/fpm/pool.d/www.conf"

RUN ( \
		echo "#!/usr/bin/env sh"                                       ; \
		echo "cat /dev/urandom | tr -dc [:alnum:] | head -c \${1:-16}" ; \
		echo "echo"                                                    ; \
	) | tee ./random.sh

RUN ( \
		echo "<?php"                                                   ; \
		echo "\$table_prefix = 'wp_';"                                 ; \
		echo "define('RELOCATE',     true  );"                         ; \
		echo "define('DB_CHARSET',  'utf8' );"                         ; \
		echo "define('DB_COLLATE',  'utf8_general_ci' );"              ; \
		echo "define('DB_NAME',     getenv('DB_NAME') );"              ; \
		echo "define('DB_USER',     getenv('DB_USER') );"              ; \
		echo "define('DB_PASSWORD', getenv('DB_PASS') );"              ; \
		echo "define('DB_HOST',     getenv('DB_HOST') );"              ; \
		echo "define('AUTH_KEY',         '$(bash random.sh 24)' );"    ; \
		echo "define('SECURE_AUTH_KEY',  '$(bash random.sh 24)' );"    ; \
		echo "define('LOGGED_IN_KEY',    '$(bash random.sh 24)' );"    ; \
		echo "define('NONCE_KEY',        '$(bash random.sh 24)' );"    ; \
		echo "define('AUTH_SALT',        '$(bash random.sh 24)' );"    ; \
		echo "define('SECURE_AUTH_SALT', '$(bash random.sh 24)' );"    ; \
		echo "define('LOGGED_IN_SALT',   '$(bash random.sh 24)' );"    ; \
		echo "define('NONCE_SALT',       '$(bash random.sh 24)' );"    ; \
		echo "define('WP_DEBUG',                   true    );"         ; \
		echo "define('WP_DEBUG_LOG',               true    );"         ; \
		echo "define('WP_DEBUG_DISPLAY',           false   );"         ; \
		echo "define('DISABLE_WP_CRON',            false   );"         ; \
		echo "define('AUTOMATIC_UPDATER_DISABLED', false   );"         ; \
		echo "define('WP_HOME',       getenv('WP_HOME')    );"         ; \
		echo "define('WP_SITEURL',    getenv('WP_SITEURL') );"         ; \
		echo "define('FORCE_SSL',             false );"                ; \
		echo "define('FORCE_SSL_ADMIN',       false );"                ; \
		echo "define('FORCE_SSL_LOGIN',       false );"                ; \
		echo "define('WP_AUTO_UPDATE_CORE', 'minor' );"                ; \
		echo "if ( ! defined( 'ABSPATH' ) ) {"                         ; \
		echo "  define( 'ABSPATH', dirname( __FILE__ ) . '/' );"       ; \
		echo "}"                                                       ; \
		echo "require_once( ABSPATH . 'wp-settings.php' );"            ; \
		echo "?>"                                                      ; \
	) | tee ./wp-config.php

RUN touch ./wp-content/debug.log
RUN echo "<?php phpinfo(); ?>" | tee ./info.php
RUN chown -R www-data:users .
RUN truncate -s0 /var/log/mysql/error.log

#VOLUME /var/lib/mysql
ENV PHP_VER "${PHP_VER}"
ENV DB_USER "${MYSQL_USER:-root}"
ENV DB_PASS "${MYSQL_PASS:-1234}"
ENV DB_PORT "${MYSQL_PORT:-3306}"
ENV DB_HOST "${MYSQL_HOST:-localhost}"
ENV DB_NAME "${MYSQL_NAME:-wordpress}"
ENV WP_HOME    ""
ENV WP_SITEURL ""
#RUN chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
CMD date; hostname; \
	test -z "${WP_HOME}"    &&    WP_HOME="/" ; \
	test -z "${WP_SITEURL}" && WP_SITEURL="/" ; \
	/bin/sh -c export \
		| grep -e DB_ -e WP_ \
		| tee -a "/etc/default/php-fpm${PHP_VER}" >/dev/null; \
	for i in "mysql" "php${PHP_VER}-fpm" "nginx"; do \
		echo "Staring: ${i}"; \
		service "${i}" start; \
	done; \
	mysql -BEno -h"${DB_HOST}" -P"${DB_PORT}" -u"root" -p"${DB_PASS}" -e "\
		SELECT PASSWORD('${DB_PASS}') as '${DB_PASS}';                    \
		CREATE SCHEMA ${DB_NAME};                                         \
		UPDATE user SET                                                   \
			Host='%',                                                     \
			User='${DB_USER}',                                            \
			plugin='mysql_native_password',                               \
			Password=PASSWORD('${DB_PASS}')                               \
			WHERE User='root';                                            \
		SELECT Host, User, Password, plugin from user;                    \
		FLUSH PRIVILEGES; SELECT SLEEP(1) from user;                      \
	" mysql \
	&& test -e init.sh \
	&& init.sh \
	|| sleep 0 \
	&& tail -f \
		/var/log/php${PHP_VER}-fpm.log \
		/var/log/nginx/access.log \
		/var/log/nginx/error.log \
		/var/log/mysql/error.log \
		./wp-content/debug.log \
		/tmp/log \
		| ccze -A

HEALTHCHECK \
	--timeout=10s \
	--interval=5m \
	--start-period=1s \
	CMD curl -skLfm1 localhost
