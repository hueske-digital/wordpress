ARG PHP_VERSION=8.4

FROM rust:alpine AS builder
RUN cargo install svgcleaner

FROM serversideup/php:${PHP_VERSION}-fpm-alpine
USER root
RUN apk add --no-cache msmtp libwebp-tools libjpeg-turbo-utils gifsicle optipng pngquant
RUN install-php-extensions mysqli
RUN install-php-extensions intl
RUN install-php-extensions exif
RUN install-php-extensions gd
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/bin/wp
COPY --from=builder /usr/local/cargo/bin/svgcleaner /usr/bin/svgcleaner
RUN docker-php-serversideup-set-id www-data 1000:1000 && \
    docker-php-serversideup-set-file-permissions --owner 1000:1000 --service fpm
USER www-data
