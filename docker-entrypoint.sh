#!/bin/sh
set -e

mkdir -p \
    /app/logs \
    /app/logs/chat \
    /app/logs/modlog \
    /app/logs/repl \
    /app/logs/tickets \
    /app/logs/ladderip \
    /app/databases

# Bootstrap config.js when a fresh persistent volume is mounted at /app/config.
# (When no volume is mounted, the build step has already created this file.)
if [ ! -f /app/config/config.js ]; then
    if [ -f /app/config/config-example.js ]; then
        echo "[entrypoint] config/config.js missing — seeding from config-example.js"
        cp /app/config/config-example.js /app/config/config.js
    else
        echo "[entrypoint] FATAL: neither config/config.js nor config/config-example.js exist." >&2
        echo "[entrypoint] Your /app/config volume looks empty — restore it or remove the mount so the image defaults are used." >&2
        exit 1
    fi
fi

exec "$@"
