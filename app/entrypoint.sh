#!/bin/sh
set -eu

mkdir -p \
    /var/log/mft \
    /var/www/storage \
    /var/www/html/uploads

chown -R www-data:www-data \
    /var/log/mft \
    /var/www/storage

chmod -R 775 \
    /var/log/mft \
    /var/www/storage

# ./uploads bind mount의 호스트 권한에도 그대로 반영됨
chmod 0777 /var/www/html/uploads

# rsyslog creates /dev/log for PHP's syslog() calls.
rsyslogd

exec php-fpm -F