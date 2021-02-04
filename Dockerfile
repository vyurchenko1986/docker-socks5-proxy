FROM  alpine:latest

LABEL maintainer="Valery Yurchenko <vyurchenko1986@gmail.com>"
LABEL company="My Home Company"
LABEL name="SOCKS v5 Server"

ARG tz="Europe/Kiev"
ARG service_port="1080"

# https://www.inet.no/dante/download.html
ARG dante_release="https://www.inet.no/dante/files/dante-1.4.2.tar.gz"
# https://github.com/Yelp/dumb-init/releases
ARG dumb_init_release="https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64"

ENV SERVICE_PORT=${SERVICE_PORT:-$service_port}
ENV TZ=${TZ:-$tz}

ENV DANTE_RELEASE=${DANTE_RELEASE:-$dante_release}
ENV DUMB_INIT_RELEASE=${DUMB_INIT_RELEASE:-$dumb_init_release}

RUN set -x \
    && apk update \
    && apk upgrade \
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && apk add --update tzdata \
    && apk add --no-cache \
            linux-pam \
    && apk add --no-cache -t .build-deps \
        build-base \
        curl \
        linux-pam-dev \
    && TMPDIR="$(mktemp -d)" \
    && cd $TMPDIR \
    && curl -L ${DANTE_RELEASE} | tar xz \
    && cd dante-* \
    && ac_cv_func_sched_setscheduler=no ./configure \
    && make install \
    && cd / \
    && rm -rf $TMPDIR \
    && adduser -S -D -u 8062 -H sockd \
    && curl -Lo /usr/local/bin/dumb-init ${DUMB_INIT_RELEASE} \
    && chmod +x /usr/local/bin/dumb-init \
    && apk del --purge .build-deps \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* \
    && rm -rf /var/cache/apk/* \
    && rm -rf /var/cache/distfiles/*

# Default configuration
COPY sockd.conf /etc/

EXPOSE ${SERVICE_PORT}

ENTRYPOINT ["dumb-init"]
CMD ["sockd"]
