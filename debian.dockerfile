#!/usr/bin/env -S docker build --progress=tty --compress -t pvtmert/debian:test -f

FROM debian:stable

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update
#RUN apt install -y
WORKDIR /tmp
RUN echo '\n\
man                    \n\
git                    \n\
vim                    \n\
gdb                    \n\
lldb                   \n\
llvm                   \n\
curl                   \n\
tmux                   \n\
ncdu                   \n\
nano                   \n\
less                   \n\
nmap                   \n\
nasm                   \n\
cron                   \n\
tree                   \n\
htop                   \n\
iftop                  \n\
iotop                  \n\
nginx                  \n\
sshfs                  \n\
cmake                  \n\
clang                  \n\
golang                 \n\
nodejs                 \n\
bcrypt                 \n\
ccrypt                 \n\
airspy                 \n\
procps                 \n\
x11vnc                 \n\
python3                \n\
tcpdump                \n\
php-fpm                \n\
locales                \n\
hfsplus                \n\
binwalk                \n\
dnsmasq                \n\
unbound                \n\
testdisk               \n\
automake               \n\
autoconf               \n\
dfu-util               \n\
bsdutils               \n\
binutils               \n\
dnsutils               \n\
elfutils               \n\
hfsutils               \n\
hfsprogs               \n\
net-tools              \n\
diffutils              \n\
dateutils              \n\
coreutils              \n\
cronutils              \n\
mailutils              \n\
moreutils              \n\
findutils              \n\
traceroute             \n\
cloud-init             \n\
vnc4server             \n\
pkg-config             \n\
cifs-utils             \n\
subversion             \n\
exfat-fuse             \n\
debianutils            \n\
exfat-utils            \n\
aircrack-ng            \n\
avahi-utils            \n\
avahi-daemon           \n\
bsdmainutils           \n\
clang-format           \n\
airport-utils          \n\
avahi-autoipd          \n\
squashfs-tools         \n\
avahi-discover         \n\
suckless-tools         \n\
bash-completion        \n\
build-essential        \n\
default-jdk-headless   \n\
default-mysql-client   \n\
' | tee packages

RUN true \
	&& apt update \
	&& apt install -y $(cat packages) \
	&& apt clean \
	&& apt autoclean \
	&& apt autoremove \
	&& du -hs /usr /var

RUN apt install -y locales localepurge
RUN echo "en_US.UTF-8 UTF-8" \
	| tee -a /etc/locale.gen \
	&& locale-gen

ENV USER root
CMD login -f ${USER} || su - ${USER}
