#!/usr/bin/env docker build --compress -t pvtmert/openfire -f

FROM debian:stable

WORKDIR /data

RUN apt update && apt install -y \
	net-tools procps curl default-jre nginx git nano && \
	apt clean

#RUN curl -#kL https://www.igniterealtime.org/downloadServlet?filename=openfire/openfire_4_3_2.tar.gz | tar -zx
RUN curl -#kL https://github.com/igniterealtime/Openfire/releases/download/v4.1.6/openfire_4_1_6.tar.gz | tar -zx

RUN rm -rf /var/www/html && \
	git clone https://github.com/igniterealtime/webmeet.git \
	openfire/resources/spank/demo

#RUN sed -i 's/# listen/listen/g' /etc/nginx/sites-enabled/default
#RUN sed -i 's/# include/include/g' /etc/nginx/sites-enabled/default

RUN cd openfire/plugins; \
	curl -#kLO https://www.igniterealtime.org/projects/openfire/plugins/1.2.1/websocket.jar

RUN cd openfire/plugins; \
	curl -#kLO https://www.igniterealtime.org/projects/openfire/plugins/4.1.2.1/inverse.jar

CMD /data/openfire/bin/openfire run

# docker run --rm -itp 5220-5280:5220-5280 -p 9090:9090 -p 7777:7777 -p 7070:7070 -p 7443:7443 -p 80:80 pvtmert/openfire
