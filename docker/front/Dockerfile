# Stage 1: Build React app with Webpack
FROM node:24-alpine AS builder
WORKDIR /app
COPY package.json ./package.json
COPY package-lock.json ./package-lock.json
RUN npm ci
COPY . .
RUN npm run build:run

# Stage 2: Serve with nginx
FROM nginx:alpine

ENV DEV=false
ENV HOST=127.0.0.1
ENV API_URL=https://127.0.0.1/api
ENV DATA_URL=https://127.0.0.1/data

COPY docker/front/nginx.conf /etc/nginx/conf.d/default.conf
COPY docker/front/runtime-config.json.template /runtime-config.json.template
COPY docker/front/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /app/build .

VOLUME /mounted

ENTRYPOINT ["/entrypoint.sh"]
