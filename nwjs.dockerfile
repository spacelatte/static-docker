#!/usr/bin/env -S docker build --compress -t pvtmert/nwjs -f

ARG VERSION=0.44.1
ARG WITHSDK=-sdk
ARG BASE=debian
FROM ${BASE} AS build

RUN apt update
RUN apt install -y \
	libasound2        \
	libatk1.0         \
	libatspi2.0       \
	libcups2          \
	libglib2.0        \
	libgtk-3-0        \
	libnss3           \
	libpangocairo-1.0 \
	libx11-6          \
	libx11-xcb1       \
	libxcomposite1    \
	libxcursor1       \
	libxdamage1       \
	libxext6          \
	libxi6            \
	libxrandr2        \
	libxss1           \
	libxtst6          \
	libatomic1        \
	curl

WORKDIR /data
ARG VERSION
ARG WITHSDK
RUN curl --compressed -#L "https://dl.nwjs.io/v${VERSION}/nwjs${WITHSDK}-v${VERSION}-linux-x64.tar.gz" \
	| tar --strip=1 -xzC .

ARG DEBIAN_FRONTEND=noninteractive
RUN apt install -y --no-install-recommends libgl1 xterm gnome-core task-desktop

ENV NW_PRE_ARGS "\
	--no-sandbox                    \
	--disable-gpu                   \
	--force-cpu-draw                \
	--use-gl=swiftshader            \
	--disable-accelerated-video     \
	--disable-accelerated-2d-canvas \
	"

ENV DISPLAY :0
ENV LIBGL_DEBUG verbose
ENV LIBGL_ALWAYS_SOFTWARE 1
ENV LIBGL_ALWAYS_INDIRECT 1
ENV MESA_GL_VERSION_OVERRIDE 4.5
ENV MESA_LOADER_DRIVER_OVERRIDE iris
RUN ( \
	echo '#!/usr/bin/env bash' ; \
	echo '#service dbus start' ; \
	echo 'exec ./nw $@'        ; \
	) | tee -a init.sh
RUN chmod +x ./init.sh
ENTRYPOINT [ "./init.sh" ]
CMD        [ ]
