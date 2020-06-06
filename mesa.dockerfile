#!/usr/bin/env -S docker build --compress -t pvtmert/mesa -f

FROM debian:stable

RUN apt update
RUN apt install -y mesa-utils

ENV LIBGL_DEBUG verbose
ENV LIBGL_ALWAYS_SOFTWARE 1
ENV LIBGL_ALWAYS_INDIRECT 1
ENV MESA_GL_VERSION_OVERRIDE 4.5
ENV MESA_LOADER_DRIVER_OVERRIDE iris
ENV DISPLAY host.docker.internal:0

RUN ( \
	echo '<driconf>'                                                 ; \
	echo '   <device screen="0" driver="radeon">'                    ; \
	echo '      <application name="all">'                            ; \
	echo '         <option name="vblank_mode" value="3"/>'           ; \
	echo '      </application>'                                      ; \
	echo '      <application name="glxgears" executable="glxgears">' ; \
	echo '         <option name="vblank_mode" value="3"/>'           ; \
	echo '      </application>'                                      ; \
	echo '   </device>'                                              ; \
	echo '</driconf>'                                                ; \
) | tee /etc/drirc.test

CMD glxinfo && vblank_mode=3 glxgears
