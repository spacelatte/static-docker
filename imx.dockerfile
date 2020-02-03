#!/usr/bin/env -S docker build --compress -t linux -f

FROM debian:10

#RUN echo deb http://emdebian.org/tools/debian/ jessie main | tee /etc/apt/sources.list.d/tools.list
RUN dpkg --add-architecture armhf
RUN apt update
RUN apt install -y build-essential curl bc kmod cpio flex cpio libncurses5-dev xz-utils less nano lzop
#RUN curl -#L http://emdebian.org/tools/debian/emdebian-toolchain-archive.key | apt-key add -
RUN apt install -y \
	crossbuild-essential-armhf \
	gcc-arm-linux-gnueabihf \
	gcc-arm-none-eabi \
	nano curl

RUN curl -#L https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/arm-linux-gnueabihf/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf.tar.xz \
	| xz -dcT$(nproc) | tar --strip=1 -C /opt -ox

WORKDIR /data
#RUN curl -#L https://cdn.kernel.org/pub/linux/kernel/v3.x/linux-3.14.52.tar.xz \
#	| xz -dcT$(nproc) | tar --strip=1 -ox

#RUN curl -#L https://cdn.kernel.org/pub/linux/kernel/v3.x/linux-3.14.69.tar.xz \
#	| xz -dcT$(nproc) | tar --strip=1 --wildcards -ox 'linux-*/include/linux/compiler-gcc*'

RUN curl -#L http://git.freescale.com/git/cgit.cgi/imx/linux-2.6-imx.git/snapshot/rel_imx_3.14.52_1.1.1_ga.tar.gz \
	| tar --strip=1 -oxz

#RUN curl -#L http://git.freescale.com/git/cgit.cgi/imx/linux-2.6-imx.git/snapshot/rel_imx_4.1.15_1.2.0_ga.tar.gz \
#	| tar --strip=1 -oxz

ENV ARCH arm
ENV CROSS_COMPILE arm-none-eabi-
ENV CROSS_COMPILE /opt/bin/arm-linux-gnueabihf-

RUN make -j$(nproc) help | grep -i imx 1>&2
RUN make -j$(nproc) imx_v6_v7_defconfig
RUN make -j$(nproc) imx_v7_defconfig
RUN make -j$(nproc) \
	modules_prepare \
	modules \
	all \
	|| true
RUN make -j$(nproc) all             || true
RUN make -j$(nproc) allmodconfig    || true
RUN make -j$(nproc) modules_prepare || true
RUN make -j$(nproc) modules         || true
RUN make -j$(nproc) all             || true
