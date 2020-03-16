FROM dezinger/alpine-php:7.3-cli

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/dezinger/docker-alpine-php.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="dezinger" \
      org.label-schema.name="docker-alpine-php" \
      org.label-schema.description="Docker image with PHP 7.3 (FPM) and Alpine" \
      org.label-schema.url="https://github.com/dezinger/docker-alpine-php"

RUN set -xe \
# Install packages
    && apk --no-cache add \
        php7-fpm \
# Clean
    && rm -rf /var/cache/apk/*

COPY tags/fpm /

EXPOSE 9000

CMD ["/sbin/runit-wrapper"]
