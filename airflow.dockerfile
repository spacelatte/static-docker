#!/usr/bin/env -S docker build --compress -t pvtmert/airflow -f

FROM centos/systemd

RUN yum update -y
RUN yum install -y epel-release gcc gcc-c++ wget curl

RUN yum install -y python36 python36-devel python36-pip \
	mysql mysql-devel postgresql postgresql-server

RUN pip3 install -U flask apache-airflow \
		apache-airflow[mysql] apache-airflow[postgresql] \
		JayDeBeApi pyexasol[pandas] psycopg2-binary

ENV USER          airflow
ENV DBNAME        ${USER}
ENV AIRFLOW_HOME  /data
ENV AIRFLOW_DBURL "postgresql://localhost:5432/${DBNAME}?user=${USERNAME}"

WORKDIR ${AIRFLOW_HOME}

RUN systemctl enable postgresql
RUN runuser -l postgres -c 'pg_ctl init -wD /var/lib/pgsql/data'
RUN echo "listen_addresses = '*'"         | tee -a /var/lib/pgsql/data/postgresql.conf
RUN echo "host  all  all  0.0.0.0/0  md5" | tee -a /var/lib/pgsql/data/pg_hba.conf
RUN sed -i 's: ident:trust:g'                      /var/lib/pgsql/data/pg_hba.conf
RUN sed -i 's: peer: trust:g'                      /var/lib/pgsql/data/pg_hba.conf
RUN sed -i 's: md5:  trust:g'                      /var/lib/pgsql/data/pg_hba.conf

RUN ( \
		echo "#cd '${AIRFLOW_HOME}';"                                         ; \
		echo "test -e '${AIRFLOW_HOME}/.firstrun' || {"                       ; \
		echo "  touch '${AIRFLOW_HOME}/.firstrun'"                            ; \
		echo "  psql -U postgres -c '"                                        ; \
		echo "    create user ${USERNAME};"                                   ; \
		echo "    create database ${DBNAME};"                                 ; \
		echo "    grant all privileges on database ${DBNAME} to ${USERNAME};" ; \
		echo "  '"                                                            ; \
		echo "  airflow initdb"                                               ; \
		echo "}"                                                              ; \
		echo "echo scheduler webserver | xargs -n1 -P9 -- airflow &" ; \
	) | tee -a /etc/rc.local


ENV LANG "en_US.UTF-8"
ENV LC_ALL "${LANG}"
RUN airflow initdb && airflow resetdb -y \
	&& sed -i'' 's/executor = .*/executor = LocalExecutor/'     \
		"${AIRFLOW_HOME}/airflow.cfg" \
	&& sed -i'' 's/load_examples = True/load_examples = False/' \
		"${AIRFLOW_HOME}/airflow.cfg" \
	&& sed -i'' 's/expose_config = False/expose_config = True/' \
		"${AIRFLOW_HOME}/airflow.cfg" \
	&& sed -i'' "s#sql_alchemy_conn = .*#sql_alchemy_conn = ${AIRFLOW_DBURL}#" \
		"${AIRFLOW_HOME}/airflow.cfg" \
	&& sed -i'' 's/dag_run_conf_overrides_params = False/dag_run_conf_overrides_params = True/' \
		"${AIRFLOW_HOME}/airflow.cfg" \
	&& true

RUN chmod +x /etc/rc.local /etc/rc.d/rc.local; \
	passwd -df root; \
	passwd -uf root; \
	systemctl enable rc-local;

EXPOSE 5432 8080
CMD init
