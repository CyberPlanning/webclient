module Cyberplanning.Query exposing (Params, eventsApiQuery, sendRequest)

import Config
import Cyberplanning.Types exposing (Event, InternalMsg(..), Planning, Query)
import Http exposing (Body, Error, Header, Request)
import Json.Decode as Decode exposing (Decoder, field, maybe, string)
import Json.Encode as Encode


eventsApiQuery : String
eventsApiQuery =
    """query day_planning($collec: Collection!, $grs: [String], $to: DateTime!, $from: DateTime!, $hack2g2: Boolean!, $custom: Boolean!) {
        planning(collection: $collec, affiliationGroups: $grs, toDate: $to, fromDate: $from) {
            ...events
        }
        hack2g2: planning(collection: HACK2G2, toDate: $to, fromDate: $from) @include(if: $hack2g2) {
            ...events
        }
        custom: planning(collection: CUSTOM, affiliationGroups: $grs, toDate: $to, fromDate: $from) @include(if: $custom) {
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
            affiliations
        }
    }
    """


type alias Params =
    { collec : String
    , from : String
    , to : String
    , grs : List String
    , hack2g2 : Bool
    , custom : Bool
    }


post : String -> List Header -> Body -> Request Query
post url headers body =
    Http.request
        { method = "POST"
        , headers = headers
        , url = url
        , body = body
        , expect = Http.expectJson (Decode.field "data" decodeQuery)
        , timeout = Nothing
        , withCredentials = False
        }


-- authorizationHeader : String -> Header
-- authorizationHeader =
--     Http.header "Authorization"


requestAPI : (Result Error Query -> InternalMsg) -> Request Query -> Cmd InternalMsg
requestAPI =
    Http.send


requestBody : String -> Params -> Body
requestBody queryString { collec, from, to, grs, hack2g2, custom } =
    let
        var =
            Encode.object
                [ ( "collec", Encode.string collec )
                , ( "from", Encode.string from )
                , ( "to", Encode.string to )
                , ( "grs", Encode.list Encode.string grs )
                , ( "hack2g2", Encode.bool hack2g2 )
                , ( "custom", Encode.bool custom )
                ]
    in
    Encode.object
        [ ( "query", Encode.string queryString )
        , ( "variables", var )
        ]
        |> Http.jsonBody


sendRequest : Params -> Cmd InternalMsg
sendRequest params =
    requestBody eventsApiQuery params
        |> post Config.apiUrl []
        |> requestAPI GraphQlResult


decodePlanning : Decoder Planning
decodePlanning =
    Decode.map Planning
        (field "events" (Decode.list decodeEvent))


listOrNull : Decoder (Maybe (List String))
listOrNull =
    Decode.string
        |> Decode.list
        |> Decode.nullable


decodeEvent : Decoder Event
decodeEvent =
    Decode.map8 Event
        (field "title" string)
        (field "startDate" string)
        (field "endDate" string)
        (field "classrooms" listOrNull)
        (field "teachers" listOrNull)
        (field "groups" listOrNull)
        (field "affiliations" listOrNull)
        (field "eventId" string)


decodeQuery : Decoder Query
decodeQuery =
    Decode.map3 Query
        (field "planning" decodePlanning)
        (Decode.maybe (field "hack2g2" decodePlanning))
        (Decode.maybe (field "custom" decodePlanning))
