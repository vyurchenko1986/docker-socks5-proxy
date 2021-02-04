#!/usr/bin/env sh

set -e
cd "$(pwd)/.."
SQUID_DATA="socks5_data" && \
docker volume create --name $SQUID_DATA && \
docker build -t socks5 . && \
docker run -d -p 1080:1080 -e TZ="Europe/London" --name=docker-socks5-proxy --restart=always -v $SQUID_DATA:/etc/socks5 socks5 && \
docker system prune -a -f
