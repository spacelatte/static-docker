#!/usr/bin/env docker build --compress -t pvtmert/scratch -f

FROM debian:stable as debian

ENV CC      clang
ENV DIR     heirloom
ENV REPO    a.cvs.sourceforge.net::cvsroot/heirloom/
ENV CVSROOT /data/cvs

WORKDIR /data

RUN apt update && apt install -y \
	build-essential rsync clang cvs \
	&& apt clean

RUN rsync -aiz --progress $REPO $DIR
RUN find $DIR -iname "#*" -delete
RUN mkdir -p $CVSROOT && cd $CVSROOT && \
	cvs checkout -P heirloom{,-sh,-pkgtools,-devtools,-doctools}

############################################################

FROM busybox as box

ENV ARCH x86_64
ENV REPO http://landley.net/toybox/bin/toybox
ENV FILE toybox

ADD $REPO-$ARCH $FILE
RUN chmod +x $FILE

############################################################

FROM scratch

COPY --from=box toybox ./
COPY --from=box ./bin/busybox ./

RUN [ "./toybox", "mkdir", "-p", "./bin", "./sbin", "./usr/bin", "./usr/sbin" ]
RUN [ "./busybox", "ln", "-s", "../busybox", "./bin/sh" ]
#RUN [ "./toybox", "ln", "-s", "../toybox", "./bin/sh" ]
#RUN [ "./toybox", "ln", "-s", "../toybox", "./bin/ln" ]
#RUN [ "./toybox", "ln", "-s", "../toybox", "./bin/ls" ]
#RUN [ "./toybox", "ln", "-s", "../toybox", "./bin/chmod" ]
#RUN [ "./toybox", "ln", "-s", "../toybox", "./bin/chown" ]
#RUN [ "./toybox", "ln", "-s", "../toybox", "./bin/chgrp" ]

#RUN for i in $(./toybox --long); do ./busybox ln -sf ./toybox $i; done
#RUN for i in $(./busybox --list-full); do ./busybox ln -sf ../../busybox $i; done
#RUN [ "./toybox", "ln", "-sf", "../toybox", "./bin/sh" ]
#RUN [ "./toybox", "rm", "-f",  "./busybox" ]
#RUN [ "./busybox", "--install", "-s", "./usr/bin" ]
RUN ./busybox --install -s #./usr/bin

CMD [ "sh" ]
