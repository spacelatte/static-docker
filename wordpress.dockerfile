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
WORKDIR /home
RUN curl --compressed -#L "https://wordpress.org/wordpress-${VERSION}.tar.gz" \
	| tar --strip=1 -oxz

ARG PHP_VER=7.3
RUN rm /etc/nginx/sites-enabled/default \
	&& echo "\n\
server_tokens off;                                            \n\
client_max_body_size 100M;                                    \n\
error_log /tmp/log   info;                                    \n\
server {                                                      \n\
	listen  80     default_server;                            \n\
	listen 443 ssl default_server;                            \n\
	index index.php index.html;                               \n\
	autoindex on;                                             \n\
	root /home;                                               \n\
	location / {                                              \n\
		try_files                                             \n\
			\$uri                                             \n\
			\$uri/                                            \n\
			\$uri.html                                        \n\
			@extensionless-php                                \n\
			\$uri.php\$is_args\$args                          \n\
			= /index.php\$is_args\$args                       \n\
			;                                                 \n\
	}                                                         \n\
	location ~ ^/wp-content/.*\.log$ {                        \n\
		return 403 'i see what u did there';                  \n\
	}                                                         \n\
	location ~ \.php$ {                                       \n\
		set \$server 'unix:/run/php/php${PHP_VER}-fpm.sock';  \n\
		#try_files \$uri = /index.php\$is_args\$args;         \n\
		#include fastcgi_params;                              \n\
		include snippets/fastcgi-php.conf;                    \n\
		fastcgi_intercept_errors off;                         \n\
		fastcgi_pass '\$server';                              \n\
			set \$designation '\$hostname';                   \n\
			proxy_set_header Host '\$designation';            \n\
			fastcgi_param HTTP_HOST '\$designation';          \n\
			add_header 'Host' '\$designation' always;         \n\
			proxy_redirect '/' '/' ;                          \n\
			proxy_redirect 'https://\$designation/' '/' ;     \n\
			proxy_redirect 'http://\$designation/'  '/' ;     \n\
			sub_filter     'https://\$designation/' '/' ;     \n\
			sub_filter     'http://\$designation/'  '/' ;     \n\
			sub_filter_once off;                              \n\
	}                                                         \n\
	location @extensionless-php {                             \n\
		rewrite ^(.+)$ \$1.php last;                          \n\
	}                                                         \n\
}                                                             \n\
\n" | tee /etc/nginx/sites-enabled/wordpress

#RUN cat /etc/nginx/sites-enabled/wordpress
RUN nginx -t

RUN echo "\n\
post_max_size=0          \n\
max_file_uploads=100     \n\
upload_max_filesize=100M \n\
cgi.fix_pathinfo=0       \n\
\n" | tee -a "/etc/php/${PHP_VER}/fpm/php.ini"

RUN echo "\n\
[mysqld]                                                \n\
disable_log_bin                                         \n\
skip-grant-tables                                       \n\
innodb_buffer_pool_size = 32M                           \n\
#default_authentication_plugin = mysql_native_password  \n\
\n" | tee -a /etc/mysql/conf.d/mysqld.cnf

RUN sed -i'' 's:127.0.0.1:0.0.0.0:g' $(grep -rl '127.0.0.1' /etc/mysql)
RUN sed -i'' "s:;clear_env = no:clear_env = no:g" \
	"/etc/php/${PHP_VER}/fpm/pool.d/www.conf"

RUN echo "\n\
#!/usr/bin/env sh                                       \n\
cat /dev/urandom | tr -dc [:alnum:] | head -c \${1:-16} \n\
\n" | tee ./random.sh

RUN echo "\n\
<?php                                                           \n\
\$table_prefix = 'wp_';                                         \n\
//define('RELOCATE',     true  );                               \n\
define('DB_CHARSET',  'utf8' );                                 \n\
define('DB_COLLATE',  'utf8_general_ci' );                      \n\
define('DB_NAME',     getenv('DB_NAME') );                      \n\
define('DB_USER',     getenv('DB_USER') );                      \n\
define('DB_PASSWORD', getenv('DB_PASS') );                      \n\
define('DB_HOST',     getenv('DB_HOST') );                      \n\
define('AUTH_KEY',         '$(bash random.sh 24)' );            \n\
define('SECURE_AUTH_KEY',  '$(bash random.sh 24)' );            \n\
define('LOGGED_IN_KEY',    '$(bash random.sh 24)' );            \n\
define('NONCE_KEY',        '$(bash random.sh 24)' );            \n\
define('AUTH_SALT',        '$(bash random.sh 24)' );            \n\
define('SECURE_AUTH_SALT', '$(bash random.sh 24)' );            \n\
define('LOGGED_IN_SALT',   '$(bash random.sh 24)' );            \n\
define('NONCE_SALT',       '$(bash random.sh 24)' );            \n\
define('WP_DEBUG',                   false   );                 \n\
define('WP_DEBUG_LOG',               false   );                 \n\
define('WP_DEBUG_DISPLAY',           false   );                 \n\
define('DISABLE_WP_CRON',            false   );                 \n\
define('AUTOMATIC_UPDATER_DISABLED', false   );                 \n\
define('WP_HOME',         getenv('WP_HOME')    );               \n\
define('WP_SITEURL',      getenv('WP_SITEURL') );               \n\
define('FORCE_SSL',       getenv('WP_SSL')       === 'true' );  \n\
define('FORCE_SSL_ADMIN', getenv('WP_SSL_ADMIN') === 'true' );  \n\
define('FORCE_SSL_LOGIN', getenv('WP_SSL_LOGIN') === 'true' );  \n\
define('WP_AUTO_UPDATE_CORE', 'minor' );                        \n\
if ( ! defined( 'ABSPATH' ) ) {                                 \n\
	define( 'ABSPATH', dirname( __FILE__ ) . '/' );             \n\
}                                                               \n\
require_once( ABSPATH . 'wp-settings.php' );                    \n\
//error_log(print_r(get_defined_vars(), true));                 \n\
?>                                                              \n\
\n" | tee ./wp-config.php

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
RUN chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
CMD date; hostname; trap '\
		for i in "${SVC_MYSQL}" "${SVC_PHP}" "${SVC_WEB}"; do \
			service "${i}" stop; \
		done; \
		killall tail; \
	'  SIGINT SIGTERM; \
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
		SELECT PASSWORD('${DB_PASS}') AS '${DB_PASS}';                    \
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
		/var/log/nginx/access.log      \
		/var/log/nginx/error.log       \
		/var/log/mysql/error.log       \
		./wp-content/debug.log         \
		/tmp/log #| ccze -A

HEALTHCHECK \
	--timeout=10s \
	--interval=1m \
	--start-period=10s \
	CMD nginx -s reload; \
	curl -skILfm1 http://0:80

EXPOSE  \
	80  \
	443 \
	3306

VOLUME \
	/var/log \
	/var/run \
	/var/lib/mysql \
	/home/wp-content

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
