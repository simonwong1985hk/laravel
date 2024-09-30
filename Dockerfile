# nginx
FROM nginx:stable-alpine AS nginx
ENV UID=${UID:-1000}
ENV GID=${GID:-1000}
ENV USER=${USER:-laravel}
ENV GROUP=${GROUP:-laravel}
RUN addgroup -g ${GID} --system ${GROUP}
RUN adduser -u ${UID} --system ${USER} -G ${GROUP} -D -s /bin/sh
RUN sed -i "s/user  nginx/user ${USER}/g" /etc/nginx/nginx.conf
ADD ./nginx.conf /etc/nginx/conf.d/default.conf
WORKDIR /var/www/html

# php
FROM php:fpm-alpine3.19 AS php
COPY --from=composer /usr/bin/composer /usr/local/bin/composer
ENV UID=${UID:-1000}
ENV GID=${GID:-1000}
ENV USER=${USER:-laravel}
ENV GROUP=${GROUP:-laravel}
RUN addgroup -g ${GID} --system ${GROUP}
RUN adduser -u ${UID} --system ${USER} -G ${GROUP} -D -s /bin/sh
RUN sed -i "s/user = www-data/user = ${USER}/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = ${GROUP}/g" /usr/local/etc/php-fpm.d/www.conf
RUN apk update
RUN apk upgrade
RUN apk add --no-cache chromium git nodejs npm
RUN docker-php-ext-install exif
RUN apk add --no-cache libpng-dev libjpeg-turbo-dev freetype-dev
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd
RUN apk add --no-cache icu-dev
RUN docker-php-ext-install intl
RUN docker-php-ext-install pdo_mysql
RUN apk add --no-cache libzip-dev
RUN docker-php-ext-install zip
WORKDIR /var/www/html
USER ${USER}

# mysql
FROM mysql:lts AS mysql

# phpmyadmin
FROM phpmyadmin AS phpmyadmin
