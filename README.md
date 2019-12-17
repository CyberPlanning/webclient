# Cyberplanning webclient

Web calendar in [ELM lang](https://elm-lang.org/)

## Configure

Configuration file is in `src/Config.elm`

## Compile

### Via Docker

Create the image

```
docker build . --tag elm-compiler:latest
```

To build the application with the docker image:

```
docker run --rm -v $PWD:/app elm-compiler
```

This must be executed in the application folder

To start in development mode with server and hot reload:

```
docker run --rm -it -p 3000:3000 -v $PWD:/app elm-compiler start
```

### Via cli

Install `nodejs` using your package manager or [nvm](https://github.com/nvm-sh/nvm)

Install `elm` and `create-elm-app` using `npm`

```
npm install -g elm
npm install -g create-elm-app
```

Compile using [create-elm-app](https://github.com/halfzebra/create-elm-app)

```
elm-app build
```

To start in development mode with server and hot reload:

```
elm-app start
```


## Documentation

### Query GraphQL

[Cyberplanning API](https://github.com/cyberplanning/apiserver)

```js
query day_planning($grs: [String], $to: DateTime!, $from: DateTime!, $hack2g2: Boolean!, $custom: Boolean!) {
  planning(collection: CYBER, affiliationGroups: $grs, toDate: $to, fromDate: $from) {
    ...events
  }
  hack2g2: planning(collection: HACK2G2, toDate: $to, fromDate: $from) @include(if: $hack2g2) {
    ...events
  }
  custom: planning(collection: CUSTOM, toDate: $to, fromDate: $from) @include(if: $custom) {
    ...events
  }
}

fragment events on Planning {
  events {
    title
    eventId
    startDate
    endDate
    classrooms
    teachers
    groups
  }
}

```

Variables

```
{
  "from": "2018-11-12T12:00:00.000",
  "to": "2018-12-12T12:00:00.000",
  "grs": ["21"],
  "hack2g2": true,
  "custom": true
}
```
