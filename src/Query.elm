module Query exposing (Params, authorizationHeader, eventsApiQuery, post, requestAPI, requestBody, sendRequest)

import Config
import Http exposing (Body, Error, Header, Request)
import Json.Decode as Decode
import Json.Encode as Encode
import Model exposing (Settings)
import Msg exposing (Msg(..))
import Types exposing (Query, decodeQuery)


eventsApiQuery : String
eventsApiQuery =
    """query day_planning($collec: Collection!, $grs: [String], $to: DateTime!, $from: DateTime!, $hack2g2: Boolean!, $custom: Boolean!) {
        planning(collection: $collec, affiliationGroups: $grs, toDate: $to, fromDate: $from) {
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


authorizationHeader : String -> Header
authorizationHeader =
    Http.header "Authorization"


requestAPI : (Result Error Query -> Msg) -> Request Query -> Cmd Msg
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


sendRequest : String -> String -> List String -> Settings -> String -> Cmd Msg
sendRequest from to groups { showCustom, showHack2g2 } collection =
    { collec = collection
    , from = from
    , to = to
    , grs = groups
    , hack2g2 = showHack2g2
    , custom = showCustom
    }
        |> requestBody eventsApiQuery
        |> post Config.apiUrl []
        |> requestAPI GraphQlMsg
