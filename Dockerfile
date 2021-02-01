FROM  alpine:latest
MAINTAINER Valery Yurchenko <vyurchenko1986@gmail.com>

ENV TZ=Europe/Kiev

RUN set -x \
    # Runtime dependencies:
    apk update && apk upgrade && \
    apk add --no-cache squid=4.13-r0 apache2-utils && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apk add --update tzdata && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# Needed by scripts
ENV SQUID=/etc/socks5

VOLUME ["/etc/socks5"]

# Internally uses port 1080/tcp
EXPOSE 1080/tcp

ADD ./config /etc/socks5
ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

CMD ["socks5_run"]
