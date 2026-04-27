# Stage 1: Build
FROM node:22-alpine AS builder

WORKDIR /app

# Install dependencies first (layer cache)
COPY package.json package-lock.json* ./
RUN npm ci

# Copy all source files
COPY . .

# Create config.js from example (override via mounted volume or ENV-driven entrypoint)
RUN cp config/config-example.js config/config.js

# Compile TypeScript to dist/
RUN node build

# Stage 2: Production
FROM node:22-alpine

WORKDIR /app

# Copy package manifest and pre-installed node_modules from builder
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules

# Copy compiled output
COPY --from=builder /app/dist ./dist

# Copy runtime data
COPY --from=builder /app/config ./config
COPY --from=builder /app/data ./data
COPY --from=builder /app/translations ./translations

# Copy launcher script (needs execute bit)
COPY --from=builder /app/pokemon-showdown ./pokemon-showdown
RUN chmod +x ./pokemon-showdown

# Create writable runtime directories
RUN mkdir -p logs/chat logs/modlog logs/repl logs/tickets databases

# Pokemon Showdown listens on 8000 by default.
# Set PORT env var in Coolify to override (e.g. PORT=3000).
EXPOSE 8000

# Health check against the HTTP endpoint served by SockJS
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget -q --spider "http://localhost:${PORT:-8000}" || exit 1

# Pass the PORT env var as a positional arg so the server overrides Config.port.
# --skip-build avoids re-running `node build` on every container start.
CMD ["sh", "-c", "node pokemon-showdown --skip-build ${PORT:-8000}"]
