#!/usr/bin/env -S docker build --compress -t pvtmert/h2o -f

ARG BASE=debian:stable
FROM ${BASE} AS build

RUN apt update
RUN apt install -y \
	default-jre-headless

RUN apt install -y \
	curl unzip

ARG H2O_VER=3.28.0.2
ARG H2O_URL=http://h2o-release.s3.amazonaws.com/h2o/rel-yu/2/h2o-${H2O_VER}.zip

WORKDIR /data
RUN curl -#OL "${H2O_URL}"
RUN unzip -jo "$(basename "${H2O_URL}")" "h2o-${H2O_VER}/h2o.jar"
RUN rm -rf    "$(basename "${H2O_URL}")"


FROM ${BASE}

RUN apt update
RUN apt install -y \
	default-jre-headless

WORKDIR /data
COPY --from=build /data ./

EXPOSE 54321 54322
ENTRYPOINT [ "java", "-jar", "h2o.jar" ]
CMD        [ ]
