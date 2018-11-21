module Types exposing (Event, Planning, Query, decodeEvent, decodePlanning, decodeQuery)

import Json.Decode as Decode exposing (Decoder, field, int, maybe, string)


type alias Planning =
    { events : List Event
    }


type alias Event =
    { title : String
    , startDate : String
    , endDate : String
    , classrooms : Maybe (List String)
    , teachers : Maybe (List String)
    , groups : Maybe (List String)
    , eventId : String
    }


type alias Query =
    { planning : Planning
    , hack2g2 : Maybe Planning
    , custom : Maybe Planning
    }


decodePlanning : Decoder Planning
decodePlanning =
    Decode.map Planning
        (field "events" (Decode.list decodeEvent))


listnull : Decoder (Maybe (List String))
listnull =
    Decode.string
    |> Decode.list
    |> Decode.nullable


decodeEvent : Decoder Event
decodeEvent =
    Decode.map7 Event
        (field "title" string)
        (field "startDate" string)
        (field "endDate" string)
        (field "classrooms" listnull)
        (field "teachers" listnull)
        (field "groups" listnull)
        (field "eventId" string)


decodeQuery : Decoder Query
decodeQuery =
    Decode.map3 Query
        (field "planning" decodePlanning)
        (Decode.maybe (field "hack2g2" decodePlanning))
        (Decode.maybe (field "custom" decodePlanning))
