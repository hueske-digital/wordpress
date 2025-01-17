ARG PHP_VERSION

FROM serversideup/php:${PHP_VERSION}-fpm-alpine AS builder
USER root
RUN apk add --no-cache libwebp-tools libjpeg-turbo-utils gifsicle optipng pngquant su-exec
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/bin/wp

FROM rust:alpine AS builder2
RUN cargo install svgcleaner

FROM serversideup/php:${PHP_VERSION}-fpm-alpine
USER root
RUN apk add --no-cache msmtp
RUN install-php-extensions mysqli
RUN install-php-extensions imagick
COPY --from=builder /usr/bin/cwebp /usr/bin/cwebp
COPY --from=builder /usr/bin/jpegtran /usr/bin/jpegtran
COPY --from=builder /usr/bin/gifsicle /usr/bin/gifsicle
COPY --from=builder /usr/bin/optipng /usr/bin/optipng
COPY --from=builder /usr/bin/pngquant /usr/bin/pngquant
COPY --from=builder /usr/bin/wp /usr/bin/wp
COPY --from=builder /sbin/su-exec /sbin/su-exec
COPY --from=builder2 /usr/local/cargo/bin/svgcleaner /usr/bin/svgcleaner
RUN docker-php-serversideup-set-id www-data 1000:1000 && \
    docker-php-serversideup-set-file-permissions --owner 1000:1000 --service fpm
USER www-data