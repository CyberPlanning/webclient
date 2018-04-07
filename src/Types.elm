module Types exposing (..)

import Json.Decode as Decode exposing (Decoder, field, maybe, int, string)


type alias Planning =
    { events : (List Event)
    }


type alias Event =
    { title : String
    , startDate : String
    , endDate : String
    , classrooms : (List String)
    , teachers : (List String)
    , groups : (List String)
    , eventId : String
    }


type alias Query =
    { planning : Planning
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
    Decode.map Query
        (field "planning" decodePlanning)
