#!/usr/bin/env -S docker build --compress -t pvtmert/webdev -f

FROM debian

RUN apt update
RUN apt dist-upgrade -y
RUN apt install -y nano net-tools \
	nginx default-mysql-client zlib1g-dev php-fpm php-mysql \
	php-curl php-zip php-gd php-mbstring php-xml \
	postgresql-all ssl-cert

RUN echo mysql-server mysql-server/root_password       password "" | debconf-set-selections
RUN echo mysql-server mysql-server/root_password_again password "" | debconf-set-selections
RUN apt install -y default-mysql-server

RUN echo "listen_addresses = '*'" | tee -a /etc/postgresql/9.6/main/postgresql.conf
RUN echo "host  all  all  0.0.0.0/0  md5" | tee -a /etc/postgresql/9.6/main/pg_hba.conf
RUN sed -i 's: md5: trust:g' /etc/postgresql/9.6/main/pg_hba.conf
#RUN ln -s ../data/www /srv/www

RUN ( \
	echo 'server {'                                            ;\
	echo '  listen 80 default_server;'                         ;\
	echo '  listen 443 ssl default_server;'                    ;\
	echo '  include snippets/snakeoil.conf;'                   ;\
	echo '  server_name _;'                                    ;\
	echo '  root /data;'                                       ;\
	echo '  index index.html index.htm index.php;'             ;\
	echo '  location / {'                                      ;\
	echo '    autoindex on;'                                   ;\
	echo '    try_files $uri $uri/ =404;'                      ;\
	echo '  }'                                                 ;\
	echo '  location ~ \.php$ {'                               ;\
	echo '    include snippets/fastcgi-php.conf;'              ;\
	echo '    fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;' ;\
	echo '  }'                                                 ;\
	echo '}'                                                   ;\
) | tee /etc/nginx/sites-enabled/default

RUN sed -i 's: = 127.0.0.1: = 0.0.0.0:g' /etc/mysql/mariadb.conf.d/50-server.cnf
RUN service mysql start; until test -e /var/run/mysqld/mysqld.sock; do \
	sleep 1; done; sleep 1; mysql -uroot -e "                    \
	DROP USER 'root'@'localhost';                                \
	CREATE USER 'root'@'%' IDENTIFIED BY '';                     \
	GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; \
	FLUSH PRIVILEGES;                                            \
	"; service mysql stop

WORKDIR /data
EXPOSE 80 443 3306 5432

CMD true; \
	service postgresql start; \
	service php7.0-fpm start; \
	service mysql start; \
	service nginx start; \
	tail -f \
		/var/log/php7.0-fpm.log   \
		/var/log/mysql/error.log  \
		/var/log/nginx/error.log  \
		/var/log/nginx/access.log \
		/var/log/postgresql/postgresql-9.6-main.log
