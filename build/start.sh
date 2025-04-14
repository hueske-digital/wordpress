#!/bin/sh

echo "Running gomplate to generate /etc/msmtprc..."
gomplate -f /etc/msmtprc.tmpl -o /etc/msmtprc

echo "Starting watchexec to monitor /usr/local/etc/php/conf.d/zzzz-user.ini..."
watchexec -p -w /usr/local/etc/php/conf.d/zzzz-user.ini -d 250ms "
  echo 'Change detected! Reloading php-fpm...'
  pkill -o -USR2 php-fpm
  echo 'Done'
" &

echo "Starting php-fpm..."
exec php-fpm