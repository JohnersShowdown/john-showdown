#!/bin/sh
set -e

# If dist/ has not been compiled yet (first start, or volume was wiped),
# compile now. This runs inside the container, not during docker build, so
# it does NOT count against Coolify's image-build timeout.
if [ ! -f /app/dist/server/index.js ]; then
    echo "[entrypoint] dist/ not found — running 'node build' (this may take a minute on first start)..."
    node build
    echo "[entrypoint] Build complete."
fi

# Start the server. --skip-build prevents pokemon-showdown from re-running
# 'node build' on every launch. PORT defaults to 8000.
exec node pokemon-showdown --skip-build "${PORT:-8000}"
