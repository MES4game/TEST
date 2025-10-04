ARG DOCKER_CONFIG_FOLDER=./docker/front

# Stage 1: Build React app with Webpack
FROM node:24-alpine AS builder
WORKDIR /app
COPY ./package.json ./package.json
COPY ./package-lock.json ./package-lock.json
RUN npm ci
COPY . .
RUN npm run build:run -- --output-path=/build

# Stage 2: Serve with nginx
FROM nginx:alpine

ENV DEV=false
ENV HOST=127.0.0.1
ENV API_URL=https://127.0.0.1/api
ENV DATA_URL=https://127.0.0.1/data

COPY $DOCKER_CONFIG_FOLDER/nginx.conf /etc/nginx/conf.d/default.conf
COPY $DOCKER_CONFIG_FOLDER/runtime-config.json.template /runtime-config.json.template
COPY $DOCKER_CONFIG_FOLDER/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /build .

VOLUME /mounted

ENTRYPOINT ["/entrypoint.sh"]
