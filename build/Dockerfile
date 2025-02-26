FROM rust AS svgcleaner
RUN cargo install svgcleaner

FROM wordpress:fpm
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