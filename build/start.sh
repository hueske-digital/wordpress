#!/bin/sh

echo "Running gomplate to generate /etc/msmtprc..."
gomplate -f /etc/msmtprc.tmpl -o /etc/msmtprc

echo "Starting iniwatch to monitor /usr/local/etc/php/conf.d..."
(
    WATCH_DIR="/usr/local/etc/php/conf.d"
    echo "Watching for changes in $WATCH_DIR..."
    while inotifywait -e modify,create,delete,move "$WATCH_DIR"; do
        echo "Change detected! Reloading php-fpm..."
        pkill -o -USR2 php-fpm
        echo "Done"
    done
) &

echo "Starting php-fpm..."
exec php-fpm