FROM dezinger/alpine-php:7.3-cli

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/dezinger/docker-alpine-php.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="dezinger" \
      org.label-schema.name="docker-alpine-php" \
      org.label-schema.description="Docker image with PHP 7.3, Apache, and Alpine" \
      org.label-schema.url="https://github.com/dezinger/docker-alpine-php"

RUN set -xe \
# Install packages
    && apk --no-cache add \
        php7-apache2 \
        apache2 \
    && mkdir -p /run/apache2 \
    && ln -sf /dev/stdout /var/log/apache2/access.log \
    && ln -sf /dev/stderr /var/log/apache2/error.log \
# Clean
    && rm -rf /var/cache/apk/*

COPY tags/apache /

EXPOSE 80

CMD ["/sbin/runit-wrapper"]
