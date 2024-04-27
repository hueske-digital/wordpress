ARG PHP_VERSION=8.3

FROM wordpress:php${PHP_VERSION}-fpm-alpine as builder
RUN apk add --no-cache libwebp-tools libjpeg-turbo-utils gifsicle optipng pngquant
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/bin/wp

FROM wordpress:php${PHP_VERSION}-fpm-alpine
COPY --from=builder /usr/bin/cwebp /usr/bin/cwebp
COPY --from=builder /usr/bin/jpegtran /usr/bin/jpegtran
COPY --from=builder /usr/bin/gifsicle /usr/bin/gifsicle
COPY --from=builder /usr/bin/optipng /usr/bin/optipng
COPY --from=builder /usr/bin/pngquant /usr/bin/pngquant
COPY --from=builder /usr/bin/wp /usr/bin/wp