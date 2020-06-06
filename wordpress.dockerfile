#!/usr/bin/env -S docker build --compress -t pvtmert/wordpress -f

FROM debian:stable

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
	ccze default-mysql-server nano

ARG VERSION=5.4.1
WORKDIR /data
RUN curl -#L "https://wordpress.org/wordpress-${VERSION}.tar.gz" \
	| tar --strip=1 -oxz

ARG PHP_VER=7.3
RUN rm /etc/nginx/sites-enabled/default && ( \
		echo "server_tokens off;"                                       ; \
		echo "client_max_body_size 100M;"                               ; \
		echo "error_log /tmp/log   info;"                               ; \
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
		echo "      @extensionless-php"                                 ; \
		echo "      \$uri.php\$is_args\$args"                           ; \
		echo "      = /index.php\$is_args\$args"                        ; \
		echo "      ;"                                                  ; \
		echo "  }"                                                      ; \
		echo "  location ~ ^/wp-content/.*\.log$ {"                     ; \
		echo "    return 403 'i see what u did there';"                 ; \
		echo "  }"                                                      ; \
		echo "  location ~ \.php$ {"                                    ; \
		echo "    set \$server 'unix:/run/php/php${PHP_VER}-fpm.sock';" ; \
		echo "    #try_files \$uri = /index.php\$is_args\$args;"        ; \
		echo "    #include fastcgi_params;"                             ; \
		echo "    include snippets/fastcgi-php.conf;"                   ; \
		echo "    fastcgi_intercept_errors off;"                        ; \
		echo "    fastcgi_pass '\$server';"                             ; \
		echo "      set \$designation '\$hostname';"                    ; \
		echo "      proxy_set_header Host '\$designation';"             ; \
		echo "      fastcgi_param HTTP_HOST '\$designation';"           ; \
		echo "      add_header 'Host' '\$designation' always;"          ; \
		echo "      proxy_redirect '/' '/' ;"                           ; \
		echo "      proxy_redirect 'https://\$designation/' '/' ;"      ; \
		echo "      proxy_redirect 'http://\$designation/'  '/' ;"      ; \
		echo "      sub_filter     'https://\$designation/' '/' ;"      ; \
		echo "      sub_filter     'http://\$designation/'  '/' ;"      ; \
		echo "      sub_filter_once off;"                               ; \
		echo "  }"                                                      ; \
		echo "  location @extensionless-php {"                          ; \
		echo "    rewrite ^(.+)$ \$1.php last;"                         ; \
		echo "  }"                                                      ; \
		echo "}"                                                        ; \
	) | tee /etc/nginx/sites-enabled/wordpress

RUN nginx -t

RUN echo "post_max_size=0"          | tee -a "/etc/php/${PHP_VER}/fpm/php.ini"
RUN echo "max_file_uploads=100"     | tee -a "/etc/php/${PHP_VER}/fpm/php.ini"
RUN echo "upload_max_filesize=100M" | tee -a "/etc/php/${PHP_VER}/fpm/php.ini"
RUN echo "cgi.fix_pathinfo=0"       | tee -a "/etc/php/${PHP_VER}/fpm/php.ini"

RUN ( \
		echo ""; \
		echo "[mysqld]"; \
		echo "disable_log_bin"; \
		echo "skip-grant-tables"; \
		echo "innodb_buffer_pool_size = 32M"; \
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
		echo "//define('RELOCATE',     true  );"                       ; \
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
		echo "define('WP_DEBUG',                   false   );"         ; \
		echo "define('WP_DEBUG_LOG',               false   );"         ; \
		echo "define('WP_DEBUG_DISPLAY',           false   );"         ; \
		echo "define('DISABLE_WP_CRON',            false   );"         ; \
		echo "define('AUTOMATIC_UPDATER_DISABLED', false   );"         ; \
		echo "define('WP_HOME',         getenv('WP_HOME')    );"       ; \
		echo "define('WP_SITEURL',      getenv('WP_SITEURL') );"       ; \
		echo "define('FORCE_SSL',       getenv('WP_SSL')       === 'true' );" ; \
		echo "define('FORCE_SSL_ADMIN', getenv('WP_SSL_ADMIN') === 'true' );" ; \
		echo "define('FORCE_SSL_LOGIN', getenv('WP_SSL_LOGIN') === 'true' );" ; \
		echo "define('WP_AUTO_UPDATE_CORE', 'minor' );"                ; \
		echo "if ( ! defined( 'ABSPATH' ) ) {"                         ; \
		echo "  define( 'ABSPATH', dirname( __FILE__ ) . '/' );"       ; \
		echo "}"                                                       ; \
		echo "require_once( ABSPATH . 'wp-settings.php' );"            ; \
		echo "//error_log(print_r(get_defined_vars(), true));"         ; \
		echo "?>"                                                      ; \
	) | tee ./wp-config.php

RUN touch ./wp-content/debug.log
RUN echo "<?php header('Content-Type: text/plain'); var_export(\$_SERVER); ?>" | tee ./test.php
RUN echo "<?php phpinfo(); ?>" | tee ./info.php
RUN chown -R www-data:users .
RUN truncate -s0 /var/log/mysql/error.log

ARG CERT_FILE=/host
ARG CERT_HOST=localhost
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
	-days   "${CERT_DAYS}"     \
	-subj   "/CN=${CERT_HOST}"
RUN ( \
		echo "ssl_certificate     ${CERT_FILE}.crt;" ; \
		echo "ssl_certificate_key ${CERT_FILE}.key;" ; \
	) | tee -a /etc/nginx/sites-enabled/wordpress

#VOLUME /var/lib/mysql
ENV SVC_MYSQL "mysql"
ENV SVC_NGINX "nginx"
ENV SVC_WEB   "${SVC_NGINX}"
ENV SVC_PHP   "php${PHP_VER}-fpm"
ENV PHP_VER "${PHP_VER}"
ENV DB_USER "${MYSQL_USER:-root}"
ENV DB_PASS "${MYSQL_PASS:-1234}"
ENV DB_PORT "${MYSQL_PORT:-3306}"
ENV DB_HOST "${MYSQL_HOST:-localhost}"
ENV DB_NAME "${MYSQL_NAME:-wordpress}"
ENV WP_HOME    ""
ENV WP_SITEURL ""
ENV WP_SSL       "false"
ENV WP_SSL_ADMIN "false"
ENV WP_SSL_LOGIN "false"
#RUN chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
CMD date; hostname; \
	test -z "${WP_HOME}"    &&    WP_HOME="http://${HOSTNAME}" ; \
	test -z "${WP_SITEURL}" && WP_SITEURL="http://${HOSTNAME}" ; \
	/bin/sh -c export \
		| grep -e DB_ -e WP_ \
		| tee -a "/etc/default/php-fpm${PHP_VER}" >/dev/null; \
	for i in "${SVC_MYSQL}" "${SVC_PHP}" "${SVC_WEB}"; do \
		test -z "${i}" && continue; \
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
	&& tail -F \
		/var/log/php${PHP_VER}-fpm.log \
		/var/log/nginx/access.log \
		/var/log/nginx/error.log \
		/var/log/mysql/error.log \
		./wp-content/debug.log \
		/tmp/log #| ccze -A

HEALTHCHECK \
	--timeout=10s \
	--interval=1m \
	--start-period=10s \
	CMD nginx -s reload; \
	curl -skILfm1 http://0:80

EXPOSE \
	80 \
	443 \
	3306

VOLUME \
	/var/lib/mysql \
	/data/wp-content

#  Example;
#    docker run --hostname=my.blog --rm -itd -p80:80 -p443:443 pvtmert/wordpress
#    docker run --hostname=my.blog --rm -itd \
#      -p80:80 -p443:443 \
#      -e SVC_MYSQL="" \
#      -e DB_PORT="3306" \
#      -e DB_HOST="mysql.my.blog" \
#      -e DB_USER="secure_blog_user" \
#      -e DB_PASS="secure_blog_pasword" \
#      -e DB_NAME="my_wordpress_blog_schema" \
#      -e WP_SSL=true \
#      -e WP_SSL_ADMIN=true \
#      -e WP_SSL_LOGIN=true \
#      pvtmert/wordpress
