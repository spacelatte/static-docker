#!/usr/bin/env -S docker build --compress -t pvtmert/tailscale -f

ARG BASE=debian:stable
FROM ${BASE}

RUN apt update
RUN apt install -y curl procps gnupg apt-transport-https

RUN curl -#Lk https://pkgs.tailscale.com/stable/debian/buster.gpg  \
	| apt-key add -
RUN curl -#Lk https://pkgs.tailscale.com/stable/debian/buster.list \
	| tee /etc/apt/sources.list.d/tailscale.list

ENV INTERFACE "tailscale0"
RUN apt update
RUN apt install -y tailscale
RUN echo '#!/usr/bin/env bash\n\
ARGS=( "$@" )\n\
test -n "${AUTHKEY}" && ARGS+=( "--authkey=${AUTHKEY}" ) \n\
trap "tailscaled -cleanup; pkill -eP 1;" RETURN EXIT TERM HUP INT ; \n\
tailscaled --tun="${INTERFACE:-tailscale0}" &    \n\
until test -e /var/run/tailscale/tailscaled.sock \n\
do :; done && tailscale up "${ARGS[@]}" || pkill -eP 1 & \n\
wait\n' | tee /docker-entrypoint.sh

VOLUME /var/lib/tailscale
ENTRYPOINT [ "bash", "-exo", "pipefail", "/docker-entrypoint.sh" ]
CMD        [ "--accept-dns=true", "--accept-routes=true", "--host-routes=true" ]
