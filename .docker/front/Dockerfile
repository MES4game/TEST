# Stage 1: Build React app with Webpack
FROM node:24-alpine AS builder
WORKDIR /app
COPY ./package.json ./package.json
COPY ./package-lock.json ./package-lock.json
RUN npm install -g npm@latest
RUN npm ci
COPY . .
RUN npm run build:run -- --output-path=/build

# Stage 2: Serve with nginx
FROM nginx:alpine

ENV DEV=false
ENV HOST=127.0.0.1
ENV API_URL=https://127.0.0.1/api
ENV DATA_URL=https://127.0.0.1/data

COPY --from=docker_config_folder nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=docker_config_folder runtime-config.json.template /runtime-config.json.template
COPY --from=docker_config_folder entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /build .

VOLUME /mounted

ENTRYPOINT ["/entrypoint.sh"]
