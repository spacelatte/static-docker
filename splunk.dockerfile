#!/usr/bin/env -S docker build --compress -t pvtmert/splunk -f

FROM splunk/splunk

ENTRYPOINT [ ]

ENV SPLUNK_HOME /opt/splunk
ENV SPLUNK_PASSWORD "HelloWorld:00!"
ENV SPLUNK_START_ARGS "--accept-license"

CMD [ "/sbin/entrypoint.sh", "start" ]
