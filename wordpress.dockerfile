#!/usr/bin/env -S docker build --compress -t pvtmert/wordpress -f

#FROM centos:6

FROM debian:9

ARG MYSQL_PASS=password
RUN echo mysql-server mysql-server/root_password       password "${MYSQL_PASS}" | debconf-set-selections
RUN echo mysql-server mysql-server/root_password_again password "${MYSQL_PASS}" | debconf-set-selections

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y \
	curl nginx \
	php-fdomdocument \
	php-fpm php-mysql \
	default-mysql-server

ARG VERSION=5.2.4
WORKDIR /data
RUN curl -#L https://wordpress.org/wordpress-${VERSION}.tar.gz \
	| tar --strip=1 -oxz

ARG PHP_VER=7.0
RUN rm /etc/nginx/sites-enabled/default && ( \
		echo "#error_log /tmp/log debug;"                              ; \
		echo "server {"                                               ; \
		echo "  listen 80 default_server;"                            ; \
		echo "  listen 443 ssl default_server;"                       ; \
		echo "  index index.php index.html;"                          ; \
		echo "  root /data;"                                          ; \
		echo "  #location / {"                                         ; \
		echo "    try_files \$uri \$uri/ /index.php\$is_args\$args;"  ; \
		echo "  #}"                                                    ; \
		echo "  location ~ \.php$ {"                                  ; \
		echo "    include snippets/fastcgi-php.conf;"                 ; \
		echo "    fastcgi_intercept_errors on;"                       ; \
		echo "    fastcgi_pass unix:/run/php/php${PHP_VER}-fpm.sock;" ; \
		echo "  }"                                                    ; \
		echo "}"                                                      ; \
	) | tee /etc/nginx/sites-enabled/wordpress

#RUN echo "cgi.fix_pathinfo=0" | tee -a "/etc/php/${PHP_VER}/fpm/php.ini"

RUN ( \
		echo ""; \
		echo "[mysqld]"; \
		echo "#skip-grant-tables"; \
		echo "#default_authentication_plugin=mysql_native_password"; \
	) | tee -a /etc/mysql/conf.d/mysqld.cnf


RUN ( \
		echo "#!/usr/bin/env sh"                                      ; \
		echo "cat /dev/urandom | tr -dc [:alnum:] | head -c \${1:16}" ; \
		echo "echo"                                                   ; \
	) | tee random.sh

RUN ( \
		echo "<?php"                                                    ; \
		echo "\$table_prefix = 'wp_';"                                  ; \
		echo "define( 'WP_DEBUG',    true );"                           ; \
		echo "define( 'DB_NAME',     'wordpress' );"                    ; \
		echo "define( 'DB_USER',     'root' );"                         ; \
		echo "define( 'DB_PASSWORD', '${MYSQL_PASS}' );"                ; \
		echo "define( 'DB_HOST',     ':/var/run/mysqld/mysqld.sock' );" ; \
		echo "define( 'DB_CHARSET',  'utf8' );"                         ; \
		echo "define( 'DB_COLLATE',  '' );"                             ; \
		echo "define( 'AUTH_KEY',         '$(bash random.sh 24)' );"    ; \
		echo "define( 'SECURE_AUTH_KEY',  '$(bash random.sh 24)' );"    ; \
		echo "define( 'LOGGED_IN_KEY',    '$(bash random.sh 24)' );"    ; \
		echo "define( 'NONCE_KEY',        '$(bash random.sh 24)' );"    ; \
		echo "define( 'AUTH_SALT',        '$(bash random.sh 24)' );"    ; \
		echo "define( 'SECURE_AUTH_SALT', '$(bash random.sh 24)' );"    ; \
		echo "define( 'LOGGED_IN_SALT',   '$(bash random.sh 24)' );"    ; \
		echo "define( 'NONCE_SALT',       '$(bash random.sh 24)' );"    ; \
		echo "if ( ! defined( 'ABSPATH' ) ) {"                          ; \
		echo "  define( 'ABSPATH', dirname( __FILE__ ) . '/' );"        ; \
		echo "}"                                                        ; \
		echo "require_once( ABSPATH . 'wp-settings.php' );"             ; \
		echo "?>"                                                       ; \
	) | tee wp-config.php

RUN chown -R www-data:users .

#VOLUME /var/lib/mysql
ENV PHP_VER "${PHP_VER}"
ENV DB_USER "${MYSQL_USER:-root}"
ENV DB_PASS "${MYSQL_PASS:-1234}"
#RUN chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
CMD for i in "mysql" "php${PHP_VER}-fpm" "nginx"; do \
		echo Staring: $i; \
		service $i start; \
	done; echo "Password: '${DB_PASS}' "; \
	mysql -BEno -u"root" -p"${DB_PASS}" -e "\
		SELECT PASSWORD('${DB_PASS}') as '${DB_PASS}'; \
		CREATE SCHEMA wordpress; \
		UPDATE user SET \
			Host='%', \
			User='${DB_USER}', \
			plugin='mysql_native_password', \
			Password=PASSWORD('${DB_PASS}') \
			WHERE User='root'; \
		SELECT Host, User, Password, plugin from user; \
		FLUSH PRIVILEGES; SELECT SLEEP(1) from user; \
	" mysql && test -e init.sh && init.sh || sleep 0 && tail -f \
		/var/log/php${PHP_VER}-fpm.log \
		/var/log/nginx/error.log \
		/var/log/nginx/access.log \
		/var/log/mysql/error.log \
		/tmp/log

HEALTHCHECK --start-period=1s \
	CMD curl -skfm1 localhost
