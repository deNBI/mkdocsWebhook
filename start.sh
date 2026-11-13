#!/bin/sh
webhook -urlprefix "${WEBHOOK_URL_PREFIX}" -hooks  /usr/local/bin/hooks.json  -verbose &
update.sh
/usr/sbin/httpd -D FOREGROUND -f /etc/apache2/httpd.conf

