#!/bin/sh
set -e

CONFIG=/var/www/html/config.php

# Generate config.php from environment on first boot so phpservermon knows where
# its MySQL pod lives. With a valid config the app serves its login page (or, on a
# fresh DB, 302-redirects to the web installer) instead of 403/404.
if [ ! -f "$CONFIG" ]; then
    cat > "$CONFIG" <<EOF
<?php
define('PSM_DB_PREFIX', '${PSM_DB_PREFIX:-monitor_}');
define('PSM_DB_USER', '${PSM_DB_USER:-phpservermon}');
define('PSM_DB_PASS', '${PSM_DB_PASS:-phpservermon}');
define('PSM_DB_NAME', '${PSM_DB_NAME:-phpservermon}');
define('PSM_DB_HOST', '${PSM_DB_HOST:-mysql.pod}');
define('PSM_DB_PORT', '${PSM_DB_PORT:-3306}');
define('PSM_BASE_URL', '${PSM_BASE_URL:-}');
define('PSM_WEBCRON_KEY', '${PSM_WEBCRON_KEY:-}');
EOF
    chown www-data:www-data "$CONFIG"
fi

# Best-effort wait for the MySQL pod so the first request doesn't fatal on a cold DB.
i=0
while [ "$i" -lt 30 ]; do
    if php -r '$h=getenv("PSM_DB_HOST")?:"mysql.pod"; $p=getenv("PSM_DB_PORT")?:"3306"; exit(@fsockopen($h,(int)$p,$e,$s,2)?0:1);' 2>/dev/null; then
        break
    fi
    i=$((i+1))
    sleep 2
done

exec "$@"
