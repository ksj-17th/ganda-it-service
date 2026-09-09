#!/bin/sh
set -eu

mkdir -p /var/log/mft /var/www/storage
chown -R www-data:www-data /var/log/mft /var/www/storage
chmod -R 775 /var/log/mft /var/www/storage

RUN mkdir -p /var/www/html/uploads \
    && chown -R www-data:www-data /var/www/html/uploads \
    && chmod 755 /var/www/html/uploads

# rsyslog creates /dev/log for PHP's syslog() calls.
rsyslogd
exec php-fpm -F
