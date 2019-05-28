#!/usr/bin/env docker build --compress -t pvtmert/owncloud -f

FROM debian:stable

WORKDIR /data

#COPY owncloud-10.0.10.tar.bz2 owncloud.tar.bz2
ADD https://download.owncloud.org/community/owncloud-10.0.10.tar.bz2 owncloud.tar.bz2

RUN apt update && apt install -y        \
	bzip2 apache2 libapache2-mod-php    \
	php-xml php-intl php-curl php-gd    \
	php-pgsql php-sqlite3 php-mysql     \
	php-mbstring php-fpm php-zip        \
	postgresql mysql-server             \
	&& apt clean                        \
	&& tar xf owncloud.tar.bz2          \
	&& ln -s /data/owncloud /srv/www    \
	&& rm -f /etc/nginx/sites-enabled/* \
	&& chown -R www-data:www-data /data \
	&& rm -f /etc/apache2/sites-enabled/* \
	&& echo service nginx configtest

#COPY apache.conf /etc/apache2/sites-enabled/main.conf
#COPY nginx.conf /etc/nginx/sites-enabled/main.conf

RUN ( \
	echo "<VirtualHost *:80>";                                 \
	echo "	#LogLevel info ssl:warn";                          \
	echo "	#ServerName www.example.com";                      \
	echo "	ServerAdmin webmaster@localhost";                  \
	echo "	DocumentRoot /srv/www";                            \
	echo "	#ErrorLog ${APACHE_LOG_DIR}/error.log";            \
	echo "	#CustomLog ${APACHE_LOG_DIR}/access.log combined"; \
	echo "	#Include conf-available/serve-cgi-bin.conf";       \
	echo "	<Directory /srv/www >";                            \
	echo "		Require all granted";                          \
	echo "	</Directory>";                                     \
	echo "</VirtualHost>";                                     \
) | tee /etc/apache2/sites-enabled/main.conf

CMD true \
	&& echo service php7.0-fpm start \
	&& service apache2    start \
	&& service mysql      start \
	&& mysql -uroot -e          \
	"UPDATE mysql.user SET password = PASSWORD('password') WHERE user = 'root'" \
	&& tail -F /var/log/apache2/access.log
