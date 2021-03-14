FROM node:13-alpine

WORKDIR /app

RUN npm install -g --unsafe-perm create-elm-app

EXPOSE 3000

ENTRYPOINT [ "/usr/local/bin/elm-app" ]

# to compile docker run --rm -v $PWD:/app elm-compiler
CMD [ "build" ]