#!/bin/bash
# WIT Entrypoint Script - supports both Apache and nginx
set -e

echo "=== WIT Starting (server: ${WIT_SERVER:-nginx}) ==="

# Run initialization
/opt/wit/bin/init-wit.sh

# Ensure correct ownership
chown -R www-data:www-data /opt/wit/data /opt/wit/html /opt/wit/icons

if [ "$WIT_SERVER" = "apache" ]; then
    # Start Apache
    echo "Starting Apache..."
    apachectl configtest
    exec apachectl -D FOREGROUND
else
    # Start nginx with fcgiwrap
    echo "Starting fcgiwrap..."
    spawn-fcgi -s /var/run/fcgiwrap.socket -u www-data -g www-data -- /usr/sbin/fcgiwrap
    chmod 666 /var/run/fcgiwrap.socket

    echo "Verifying nginx configuration..."
    nginx -t

    echo "Starting nginx..."
    exec nginx -g "daemon off;"
fi
