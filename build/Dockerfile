# Stage 1: Build svgcleaner
FROM rust:alpine AS svgcleaner
RUN cargo install svgcleaner

# Stage 2: Download external tools
FROM alpine:latest AS downloader
RUN apk add --no-cache curl jq tar xz

ARG TARGETARCH
WORKDIR /downloads

# Download watchexec
RUN ARCH=$(case "$TARGETARCH" in \
      "amd64") echo "x86_64" ;; \
      "arm64") echo "aarch64" ;; \
      "arm/v7") echo "armv7" ;; \
      *) echo "$TARGETARCH" ;; \
    esac) && \
    echo "Downloading watchexec for architecture: $ARCH" && \
    WATCHEXEC_VERSION=$(curl -s https://api.github.com/repos/watchexec/watchexec/releases/latest | jq -r '.tag_name' | sed 's/^v//') && \
    echo "Latest watchexec version: $WATCHEXEC_VERSION" && \
    curl -L "https://github.com/watchexec/watchexec/releases/download/v${WATCHEXEC_VERSION}/watchexec-${WATCHEXEC_VERSION}-${ARCH}-unknown-linux-gnu.tar.xz" -o watchexec.tar.xz && \
    tar -xf watchexec.tar.xz && \
    mv watchexec-${WATCHEXEC_VERSION}-${ARCH}-unknown-linux-gnu/watchexec /downloads/watchexec && \
    chmod +x /downloads/watchexec

# Download WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /downloads/wp-cli.phar

# Stage 3: Main application
FROM serversideup/php:8-fpm
USER root

# Install PHP extensions first (changes less frequently)
RUN install-php-extensions gd bcmath exif intl mysqli zip imagick imagick/imagick@3.8.0 gmp

# Install system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
      webp \
      libjpeg-turbo-progs \
      gifsicle \
      optipng \
      pngquant \
      curl \
      gosu \
      msmtp \
      ghostscript \
      procps && \
    rm -rf /var/lib/apt/lists/*

# Copy binaries from previous stages
COPY --from=svgcleaner /usr/local/cargo/bin/svgcleaner /usr/local/bin/svgcleaner
COPY --from=hairyhenderson/gomplate:stable /gomplate /usr/local/bin/gomplate
COPY --from=downloader /downloads/watchexec /usr/local/bin/watchexec
COPY --from=downloader /downloads/wp-cli.phar /usr/local/bin/wpcli

# Set up WP-CLI wrapper
RUN echo '#!/bin/sh' > /usr/local/bin/wp && \
    echo 'exec gosu 1000:1000 /usr/local/bin/wpcli "$@"' >> /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

# Configure msmtp
RUN touch /etc/msmtprc && chown 1000:1000 /etc/msmtprc

# Configure PHP settings
RUN { \
      echo 'memory_limit = 256M'; \
      echo 'cgi.fix_pathinfo = 0'; \
      echo 'upload_max_filesize = 128M'; \
      echo 'post_max_size = 128M'; \
      echo 'sendmail_path = "/usr/bin/msmtp -t"'; \
      echo 'opcache.enable = 1'; \
      echo 'opcache.enable_cli = 1'; \
      echo 'opcache.memory_consumption = 256'; \
      echo 'opcache.interned_strings_buffer = 32'; \
      echo 'opcache.max_accelerated_files = 10000'; \
      echo 'opcache.revalidate_freq = 2'; \
      echo 'error_reporting = E_ERROR | E_WARNING | E_PARSE | E_CORE_ERROR | E_CORE_WARNING | E_COMPILE_ERROR | E_COMPILE_WARNING | E_RECOVERABLE_ERROR'; \
      echo 'log_errors = On'; \
      echo 'display_errors = Off'; \
      echo 'display_startup_errors = Off'; \
      echo 'error_log = /dev/stderr'; \
      echo 'log_errors_max_len = 1024'; \
      echo 'ignore_repeated_errors = On'; \
      echo 'ignore_repeated_source = Off'; \
      echo 'html_errors = Off'; \
    } > /usr/local/etc/php/conf.d/z-custom.ini

# Copy configuration files and startup script
COPY start.sh /usr/local/bin/start.sh
COPY msmtprc.tmpl /etc/msmtprc.tmpl
COPY wp-config.tmpl /etc/wp-config.tmpl
COPY htninja.tmpl /etc/htninja.tmpl
COPY userini.tmpl /etc/userini.tmpl

# Set permissions
RUN chmod +x /usr/local/bin/start.sh && \
    docker-php-serversideup-set-id www-data 1000:1000 && \
    docker-php-serversideup-set-file-permissions --owner 1000:1000 --service fpm

USER www-data
CMD ["/usr/local/bin/start.sh"]