#!/usr/bin/env -S docker build --compress -t pvtmert/gitbook -f

FROM alpine

RUN apk add nodejs npm curl xz mesa-gl

WORKDIR /data
ENV GLIBC 2.29-r0
ENV CALIBRE https://github.com/kovidgoyal/calibre/releases/download/v3.40.1/calibre-3.40.1-x86_64.txz

RUN (cd /tmp; \
	curl -#L "${CALIBRE}" | xz -dc | tar -xC /usr/local; \
	curl -#LO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC}/glibc-${GLIBC}.apk; \
	curl -#LO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC}/glibc-bin-${GLIBC}.apk; \
	apk add --allow-untrusted glibc-${GLIBC}.apk glibc-bin-${GLIBC}.apk; \
	)

RUN npm install -g --unsafe-perm phantomjs-prebuilt gitbook-cli svgexport

RUN gitbook fetch

RUN find / -iname 'copyPluginAssets.js' -exec sed -i.old 's/confirm: true/confirm: false/g' {} +
