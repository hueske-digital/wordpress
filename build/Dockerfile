FROM rust AS svgcleaner
RUN cargo install svgcleaner


FROM serversideup/php:8-fpm
USER root

# Install PHP extensions
RUN install-php-extensions gd bcmath exif intl mysqli zip imagick imagick/imagick@3.8.0

# Combine apt-get update and package installation using BuildKit cache mounts
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
      procps \
      inotify-tools && \
    rm -rf /var/lib/apt/lists/*

# Download and configure WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wpcli && \
    echo '#!/bin/sh' > /usr/local/bin/wp && \
    echo 'exec gosu 1000:1000 /usr/local/bin/wpcli "$@"' >> /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

# Configure msmtp and PHP settings
RUN touch /etc/msmtprc && chown 1000:1000 /etc/msmtprc && \
    { \
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

# Copy over binaries and configuration from other stages
COPY --from=svgcleaner /usr/local/cargo/bin/svgcleaner /usr/local/bin/svgcleaner
COPY --from=hairyhenderson/gomplate:stable /gomplate /usr/local/bin/gomplate
COPY start.sh /usr/local/bin/start.sh
COPY msmtprc.tmpl /etc/msmtprc.tmpl

# Set file permissions and user settings
RUN docker-php-serversideup-set-id www-data 1000:1000 && \
    docker-php-serversideup-set-file-permissions --owner 1000:1000 --service fpm

USER www-data
CMD ["/usr/local/bin/start.sh"]