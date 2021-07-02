FROM node:13-alpine AS builder

WORKDIR /app

RUN npm install -g --unsafe-perm create-elm-app

COPY . .

RUN /usr/local/bin/elm-app build

FROM nginx

COPY --from=builder /app/build /usr/share/nginx/html/

EXPOSE 80
