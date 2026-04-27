FROM node:22-alpine

WORKDIR /app

# Install dependencies
COPY package.json package-lock.json* ./
RUN npm ci

# Copy all source files
COPY . .

# Create config.js from example if one is not bind-mounted at runtime
RUN cp config/config-example.js config/config.js

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create writable runtime directories (dist is intentionally left empty;
# the entrypoint builds it on first start and it persists via a volume)
RUN mkdir -p logs/chat logs/modlog logs/repl logs/tickets databases dist

# Pokemon Showdown listens on 8000 by default.
# Set PORT env var in Coolify to override (e.g. PORT=3000).
EXPOSE 8000

# Health check - start_period is long to allow first-start compilation (~2 min)
HEALTHCHECK --interval=30s --timeout=10s --start-period=180s --retries=5 \
    CMD wget -q --spider "http://localhost:${PORT:-8000}" || exit 1

ENTRYPOINT ["/entrypoint.sh"]
