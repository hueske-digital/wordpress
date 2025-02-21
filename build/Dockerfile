ARG PHP_VERSION
FROM wordpress:php${PHP_VERSION}-fpm as builder
RUN apt-get update && apt-get install -y \
    libwebp \
    libjpeg-progs \
    gifsicle \
    optipng \
    pngquant \
    curl \
    gosu \
  && rm -rf /var/lib/apt/lists/*
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x wp-cli.phar \
  && mv wp-cli.phar /usr/local/bin/wpcli
RUN echo '#!/bin/sh' > /usr/local/bin/wp \
  && echo 'exec gosu 1000:1000 /usr/local/bin/wpcli "$@"' >> /usr/local/bin/wp \
  && chmod +x /usr/local/bin/wp

FROM rust as builder2
RUN cargo install svgcleaner

FROM wordpress:php${PHP_VERSION}-fpm
RUN apt-get update && apt-get install -y msmtp \
  && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/bin/cwebp /usr/bin/cwebp
COPY --from=builder /usr/bin/jpegtran /usr/bin/jpegtran
COPY --from=builder /usr/bin/gifsicle /usr/bin/gifsicle
COPY --from=builder /usr/bin/optipng /usr/bin/optipng
COPY --from=builder /usr/bin/pngquant /usr/bin/pngquant
COPY --from=builder /usr/local/bin/wp /usr/local/bin/wp
COPY --from=builder /usr/local/bin/wpcli /usr/local/bin/wpcli
COPY --from=builder2 /usr/local/cargo/bin/svgcleaner /usr/local/bin/svgcleaner
