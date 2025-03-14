FROM rust AS svgcleaner
RUN cargo install svgcleaner

FROM wordpress:php8.4-fpm
RUN apt-get update && apt-get install -y \
    webp \
    libjpeg-turbo-progs \
    gifsicle \
    optipng \
    pngquant \
    curl \
    gosu \
    msmtp \
  && rm -rf /var/lib/apt/lists/*
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x wp-cli.phar \
  && mv wp-cli.phar /usr/local/bin/wpcli
RUN echo '#!/bin/sh' > /usr/local/bin/wp \
  && echo 'exec gosu 1000:1000 /usr/local/bin/wpcli "$@"' >> /usr/local/bin/wp \
  && chmod +x /usr/local/bin/wp
RUN touch /etc/msmtprc \
  && chown 1000:1000 /etc/msmtprc
COPY --from=svgcleaner /usr/local/cargo/bin/svgcleaner /usr/local/bin/svgcleaner
COPY --from=hairyhenderson/gomplate:stable /gomplate /usr/local/bin/gomplate
ENV TIDEWAYS_SERVICE=app
ENV TIDEWAYS_SAMPLERATE=25
ENV TIDEWAYS_CONNECTION=tcp://tideways-daemon:9135

# Use `ghcr.io/tideways/php:alpine` when using an alpine-based PHP image.
COPY --from=ghcr.io/tideways/php:latest /tideways/ /tideways/
RUN docker-php-ext-enable --ini-name tideways.ini "$(php /tideways/get-ext-path.php)"
