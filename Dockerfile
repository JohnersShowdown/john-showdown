FROM node:18-alpine

WORKDIR /app

RUN apk add --no-cache tini \
 && apk add --no-cache --virtual .build-deps python3 make g++

COPY package.json ./

RUN npm install --omit=dev --no-audit --no-fund \
 && npm cache clean --force

COPY . .

RUN node build \
 && apk del .build-deps \
 && chmod +x /app/docker-entrypoint.sh

ENV NODE_ENV=production
ENV PORT=8000

EXPOSE 8000

ENTRYPOINT ["/sbin/tini", "--", "/app/docker-entrypoint.sh"]
CMD ["sh", "-c", "exec node pokemon-showdown ${PORT}"]
