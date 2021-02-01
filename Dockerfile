FROM  alpine:latest
MAINTAINER Valery Yurchenko <vyurchenko1986@gmail.com>

ENV TZ=Europe/Kiev

RUN apk update && apk upgrade && \
    apk add --no-cache squid=4.13-r0 apache2-utils && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apk add --update tzdata && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# Needed by scripts
ENV SQUID=/etc/squid

VOLUME ["/etc/squid"]

# Internally uses port 1080/tcp
EXPOSE 1080/tcp

CMD ["squid_run"]

ADD ./config /etc/squid
ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*
