FROM  alpine:latest
LABEL Valery Yurchenko <vyurchenko1986@gmail.com>

ENV TZ=Europe/Kiev

RUN set -x \
    && apk update \
    && apk upgrade \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apk add --update tzdata \
    && apk add --no-cache \
            linux-pam \
    && apk add --no-cache -t .build-deps \
        build-base \
        curl \
        linux-pam-dev \
    && TMPDIR="$(mktemp -d)" \
    && cd $TMPDIR \
    && curl -L https://www.inet.no/dante/files/dante-1.4.2.tar.gz | tar xz \
    && cd dante-* \
    && ac_cv_func_sched_setscheduler=no ./configure \
    && make install \
    && cd / \
    && rm -rf $TMPDIR \
    && adduser -S -D -u 8062 -H dante \
    && curl -Lo /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.4/dumb-init_1.2.4_x86_64 \
    && chmod +x /usr/local/bin/dumb-init \
    && apk del --purge .build-deps \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* \
    && rm -rf /var/cache/apk/* \
    && rm -rf /var/cache/distfiles/*
# Default configuration
#COPY sockd.conf /etc/

EXPOSE 1080

ENTRYPOINT ["dumb-init"]
CMD ["sockd"]
