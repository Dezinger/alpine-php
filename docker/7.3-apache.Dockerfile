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

# Add apache to run and configure
RUN sed -i "s#\ modules/#\ /usr/lib/apache2/#g" /etc/apache2/httpd.conf /etc/apache2/conf.d/php7-module.conf \
    && sed -i "s/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ headers_module/LoadModule\ headers_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ remoteip_module/LoadModule\ remoteip_module/" /etc/apache2/httpd.conf \
    #&& sed -i "s/#LoadModule\ vhost_alias_module/LoadModule\ vhost_alias_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ deflate_module/LoadModule\ deflate_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ watchdog_module/LoadModule\ watchdog_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ logio_module/LoadModule\ logio_module/" /etc/apache2/httpd.conf \
    && sed -i "s#^DocumentRoot \".*#DocumentRoot \"/var/www/public\"#g" /etc/apache2/httpd.conf \
    && sed -i 's#AllowOverride [Nn]one#AllowOverride All#' /etc/apache2/httpd.conf \
    && sed -i 's#Directory "/var/www/localhost/htdocs.*#Directory "/var/www/public" >#g' /etc/apache2/httpd.conf \
    && sed -i 's#Directory "/var/www/localhost/cgi-bin.*#Directory "/var/www/cgi-bin" >#g' /etc/apache2/httpd.conf \
	&& sed -ri \
		-e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
		-e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
		-e 's!^(\s*TransferLog)\s+\S+!\1 /proc/self/fd/1!g' \
		"/etc/apache2/httpd.conf" \
		#"/etc/apache2/conf.d/ssl.conf" \
	&& httpd -v && httpd -M

EXPOSE 80

CMD ["/sbin/runit-wrapper"]
