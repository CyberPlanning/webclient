module Types exposing (Event, Planning, Query, decodeEvent, decodePlanning, decodeQuery)

import Json.Decode as Decode exposing (Decoder, field, int, maybe, string)


type alias Planning =
    { events : List Event
    }


type alias Event =
    { title : String
    , startDate : String
    , endDate : String
    , classrooms : List String
    , teachers : List String
    , groups : List String
    , eventId : String
    }


type alias Query =
    { planning : Planning
    , hack2g2 : Planning
    }


decodePlanning : Decoder Planning
decodePlanning =
    Decode.map Planning
        (field "events" (Decode.list decodeEvent))


decodeEvent : Decoder Event
decodeEvent =
    Decode.map7 Event
        (field "title" string)
        (field "startDate" string)
        (field "endDate" string)
        (field "classrooms" (Decode.list string))
        (field "teachers" (Decode.list string))
        (field "groups" (Decode.list string))
        (field "eventId" string)


decodeQuery : Decoder Query
decodeQuery =
    Decode.map2 Query
        (field "planning" decodePlanning)
        (field "hack2g2" decodePlanning)
