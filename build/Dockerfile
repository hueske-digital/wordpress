ARG PHP_VERSION

FROM wordpress:php${PHP_VERSION}-fpm-alpine as builder
RUN apk add --no-cache libwebp-tools libjpeg-turbo-utils gifsicle optipng pngquant su-exec msmtp
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/bin/wpcli
RUN echo '#!/bin/sh' > /usr/bin/wp \
    && echo 'exec su-exec 1000:1000 /usr/bin/wpcli "$@"' >> /usr/bin/wp \
    && chmod +x /usr/bin/wp

FROM rust:alpine as builder2
RUN cargo install svgcleaner

FROM wordpress:php${PHP_VERSION}-fpm-alpine
COPY --from=builder /usr/bin/cwebp /usr/bin/cwebp
COPY --from=builder /usr/bin/jpegtran /usr/bin/jpegtran
COPY --from=builder /usr/bin/gifsicle /usr/bin/gifsicle
COPY --from=builder /usr/bin/optipng /usr/bin/optipng
COPY --from=builder /usr/bin/pngquant /usr/bin/pngquant
COPY --from=builder /usr/bin/wp /usr/bin/wp
COPY --from=builder /usr/bin/wpcli /usr/bin/wpcli
COPY --from=builder /usr/bin/msmtp /usr/bin/msmtp
COPY --from=builder /sbin/su-exec /sbin/su-exec
COPY --from=builder2 /usr/local/cargo/bin/svgcleaner /usr/bin/svgcleaner