# webclient

Web calendar in ELM

## Query GraphQL

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
