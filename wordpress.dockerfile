#!/usr/bin/env -S docker build --compress -t pvtmert/wordpress -f

#FROM centos:6

FROM debian:10

ARG MYSQL_PASS=password
RUN echo mysql-server mysql-server/root_password       password "${MYSQL_PASS}" | debconf-set-selections
RUN echo mysql-server mysql-server/root_password_again password "${MYSQL_PASS}" | debconf-set-selections

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y \
	curl nginx \
	php-fpm php-mysql \
	default-mysql-server

ARG VERSION=5.2.4
WORKDIR /data
RUN curl -#L https://wordpress.org/wordpress-${VERSION}.tar.gz \
	| tar --strip=1 -oxz

RUN chown -R www-data:users .

RUN rm /etc/nginx/sites-enabled/default && ( \
		echo "server {"                                        ; \
		echo "  listen 80 default_server;"                     ; \
		echo "  listen 443 ssl default_server;"                ; \
		echo "  index index.php index.html;"                   ; \
		echo "  root /data;"                                   ; \
		echo "  location ~ \.php$ {"                           ; \
		echo "    include snippets/fastcgi-php.conf;"          ; \
		echo "    fastcgi_pass unix:/run/php/php7.3-fpm.sock;" ; \
		echo "  }"                                             ; \
		echo "}"                                               ; \
	) | tee /etc/nginx/sites-enabled/wordpress

RUN ( \
		echo ""; \
		echo "[mysqld]"; \
		echo "skip-grant-tables"; \
	) | tee -a /etc/mysql/conf.d/mysql.cnf


RUN ( \
		echo "<?php"                                                    ; \
		echo "\$table_prefix = 'wp_';"                                  ; \
		echo "define( 'WP_DEBUG',    true );"                           ; \
		echo "define( 'DB_NAME',     'wordpress' );"                    ; \
		echo "define( 'DB_USER',     'root' );"                         ; \
		echo "define( 'DB_PASSWORD', 'password' );"                     ; \
		echo "define( 'DB_HOST',     ':/var/run/mysqld/mysqld.sock' );" ; \
		echo "define( 'DB_CHARSET',  'utf8' );"                         ; \
		echo "define( 'DB_COLLATE',  '' );"                             ; \
		echo "define( 'AUTH_KEY',         '${RANDOM}' );"               ; \
		echo "define( 'SECURE_AUTH_KEY',  '${RANDOM}' );"               ; \
		echo "define( 'LOGGED_IN_KEY',    '${RANDOM}' );"               ; \
		echo "define( 'NONCE_KEY',        '${RANDOM}' );"               ; \
		echo "define( 'AUTH_SALT',        '${RANDOM}' );"               ; \
		echo "define( 'SECURE_AUTH_SALT', '${RANDOM}' );"               ; \
		echo "define( 'LOGGED_IN_SALT',   '${RANDOM}' );"               ; \
		echo "define( 'NONCE_SALT',       '${RANDOM}' );"               ; \
		echo "if ( ! defined( 'ABSPATH' ) ) {"                          ; \
		echo "  define( 'ABSPATH', dirname( __FILE__ ) . '/' );"        ; \
		echo "}"                                                        ; \
		echo "require_once( ABSPATH . 'wp-settings.php' );"             ; \
		echo "?>"                                                       ; \
	) | tee wp-config.php


ENV DB_PASS "${MYSQL_PASS}"
CMD for i in nginx php7.3-fpm mysql; do \
		service $i start; \
	done; echo "Password: '${DB_PASS}' "; \
	mysql -uroot -e " \
		CREATE SCHEMA wordpress; \
		UPDATE user SET \
			Host='%', \
			plugin='mysql_native_password', \
			Password=PASSWORD('${DB_PASS}') \
			WHERE User='root'; \
		SELECT Host, User, Password, plugin from user; \
		-- FLUSH PRIVILEGES; \
	" mysql && tail -f \
		/var/log/php7.3-fpm.log \
		/var/log/nginx/error.log \
		/var/log/nginx/access.log \
		/var/log/mysql/error.log
