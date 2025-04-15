#!/bin/sh

echo "Running gomplate to generate /etc/msmtprc..."
gomplate -f /etc/msmtprc.tmpl -o /etc/msmtprc

echo "Running gomplate to generate /var/www/html/.htninja..."
gomplate -f /etc/htninja.tmpl -o /var/www/html/.htninja

echo "Running gomplate to generate /var/www/html/.user.ini..."
gomplate -f /etc/userini.tmpl -o /var/www/html/.user.ini

echo "Running gomplate to generate /var/www/html/wp-config.php..."
gomplate \
  --datasource salts=https://api.wordpress.org/secret-key/1.1/salt/ \
  --file /etc/wp-config.tmpl \
  --out /var/www/html/wp-config.php

echo "Starting watchexec to monitor /usr/local/etc/php/conf.d/zzzz-user.ini..."
watchexec -p -w /usr/local/etc/php/conf.d/zzzz-user.ini -d 250ms "
  echo 'Change detected! Reloading php-fpm...'
  pkill -o -USR2 php-fpm
  echo 'Done'
" &

echo "Starting php-fpm..."
exec php-fpm