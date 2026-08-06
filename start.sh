#!/bin/sh
webhook -urlprefix "${WEBHOOK_URL_PREFIX}" -hooks  /usr/local/bin/hooks.json  -verbose &
update.sh
httpd -D FOREGROUND -f /etc/httpd/httpd.conf

