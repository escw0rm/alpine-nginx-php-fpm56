FROM alpine:3.8

RUN set -x \
    && addgroup --system --gid 101 nginx \
    && adduser -S -G nginx -H -s /sbin/nologin -u 101 -h /nonexistent -g "nginx user" nginx

RUN apk update && apk upgrade \
    && apk add nginx \
    && apk add --no-cache --upgrade bash \
    && apk add php5 php5-fpm php5-opcache \
    && apk add php5-gd php5-mysqli php5-zlib php5-curl php-mbstring php5-intl php5-xml php5-phar icu-dev php5-pdo php5-gettext php-session php5-pdo_mysql php5-sqlite3 php5-pdo_sqlite php5-dom php-simplexml \
    && mkdir -p /run/nginx

RUN mkdir -p /var/run/nginx /var/log/nginx /var/cache/nginx && \
        chown -R nginx:0 /var/run/nginx /var/log/nginx /var/cache/nginx /var/lib/nginx  && \
        chmod -R g=u /var/run/nginx /var/log/nginx /var/cache/nginx /var/lib/nginx

COPY .docker/default.conf /etc/nginx/conf.d/default.conf

COPY .docker/index.php /var/www/localhost/htdocs/index.php

COPY .docker/dhparam.pem /etc/ssl/certs/dhparam.pem
COPY .docker/self-signed.conf /etc/nginx/snippets/self-signed.conf
COPY .docker/ssl-params.conf /etc/nginx/snippets/ssl-params.conf

COPY .docker/nginx-selfsigned.crt /etc/ssl/certs/nginx-selfsigned.crt
COPY .docker/nginx-selfsigned.key /etc/ssl/private/nginx-selfsigned.key

RUN chown -R nginx:nginx /var/www/localhost/htdocs \
    && chmod 755 /var/www/localhost/htdocs

RUN ln -s /dev/stdout /var/log/nginx/access.log \
    && ln -s /dev/stderr /var/log/nginx/error.log \
    && ln -s /dev/stderr /var/log/php-fpm.log
EXPOSE 443
EXPOSE 80

ADD .docker/start.sh /
RUN chown nginx:nginx /start.sh

STOPSIGNAL SIGTERM

CMD ["sh", "/start.sh"]
