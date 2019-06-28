#!/usr/bin/env docker build --compress -t pvtmert/webdev -f

FROM debian

RUN echo mysql-server mysql-server/root_password password ""       | debconf-set-selections
RUN echo mysql-server mysql-server/root_password_again password "" | debconf-set-selections

RUN apt update && apt dist-upgrade -y && apt install -y nano net-tools \
	nginx mysql-server mysql-client zlib1g-dev php-fpm php-mysql \
	php-curl php-zip php-mcrypt php-gd php-mbstring php-xml

RUN (\
	echo 'server {';                                              \
	echo '	listen 80 default_server;';                           \
	echo '	server_name _;';                                      \
	echo '	root /data;';                                         \
	echo '	index index.html index.htm index.php;';               \
	echo '	location / {';                                        \
	echo '		autoindex on;';                                   \
	echo '		try_files $uri $uri/ =404;';                      \
	echo '	}';                                                   \
	echo '	location ~ \.php$ {';                                 \
	echo '		include snippets/fastcgi-php.conf;';              \
	echo '		fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;'; \
	echo '	}';                                                   \
	echo '}';                                                     \
) | tee /etc/nginx/sites-enabled/default

RUN service mysql start; until test -e /var/run/mysqld/mysqld.sock; do \
	sleep 1; done; sleep 1; mysql -uroot -e \
	"DROP USER 'root'@'localhost';                               \
	CREATE USER 'root'@'%' IDENTIFIED BY '';                     \
	GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; \
	FLUSH PRIVILEGES;                                            \
	"; service mysql stop

WORKDIR /data

CMD true; \
	service php7.0-fpm start; \
	service mysql start; \
	service nginx start; \
	tail -f \
		/var/log/php7.0-fpm.log   \
		/var/log/mysql/error.log  \
		/var/log/nginx/error.log  \
		/var/log/nginx/access.log \
