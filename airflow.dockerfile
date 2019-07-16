#!/usr/bin/env docker build --compress -t pvtmert/airflow -f

FROM centos:6

ENV PORT 8080

WORKDIR /data
EXPOSE ${PORT}

RUN yum update -y && \
	yum install -y epel-release centos-release-scl

RUN yum install -y gcc gcc-c++ wget curl rh-python36 \
	mysql mysql-devel postgresql postgresql-server \
	devtoolset-6-gcc devtoolset-6-gcc-c++ \
	rh-python36-python-devel

RUN source scl_source enable devtoolset-6 && \
	source scl_source enable rh-python36  && \
	pip3 install -U flask apache-airflow \
		apache-airflow[mysql] apache-airflow[postgresql] \
		JayDeBeApi pyexasol[pandas] psycopg2-binary

ENV USERNAME airflow
ENV DBNAME   ${USERNAME}
ENV AIRFLOW_HOME /data

RUN su -lc 'initdb -U postgres' postgres \
	|| service postgresql initdb; true   \
	&& service postgresql start && sleep 5              \
	&& psql -U postgres -c "create user ${USERNAME};"   \
	&& psql -U postgres -c "create database ${DBNAME};" \
	&& psql -U postgres -c "grant all privileges on database ${DBNAME} to ${USERNAME};" \
	&& service postgresql stop

RUN echo "listen_addresses = '*'"         | tee -a /var/lib/pgsql/data/postgresql.conf
RUN echo "host  all  all  0.0.0.0/0  md5" | tee -a /var/lib/pgsql/data/pg_hba.conf
RUN sed -i 's: md5: trust:g'                       /var/lib/pgsql/data/pg_hba.conf

RUN service postgresql start; \
	( \
		echo 'source scl_source enable rh-python36'  ;\
		echo 'source scl_source enable devtoolset-6' ;\
	) | tee -a /root/.bashrc \
	&& source scl_source enable devtoolset-6 \
	&& source scl_source enable rh-python36 \
	&& airflow initdb \
	&& sed -i 's/executor = .*/executor = LocalExecutor/' ${AIRFLOW_HOME}/airflow.cfg     \
	&& sed -i 's/load_examples = True/load_examples = False/' ${AIRFLOW_HOME}/airflow.cfg \
	&& sed -i 's/expose_config = False/expose_config = True/' ${AIRFLOW_HOME}/airflow.cfg \
	&& sed -i 's/dag_run_conf_overrides_params = False/dag_run_conf_overrides_params = True/' \
		${AIRFLOW_HOME}/airflow.cfg \
	&& sed -i "s#sql_alchemy_conn = .*#sql_alchemy_conn = postgresql://localhost:5432/${DBNAME}?user=${USERNAME}#" \
		${AIRFLOW_HOME}/airflow.cfg \
	&& airflow resetdb -y \
	&& airflow initdb     \
	&& service postgresql stop

CMD service postgresql start; \
	source scl_source enable rh-python36 && airflow initdb && \
	echo scheduler webserver | xargs -n1 -P9 -- airflow
