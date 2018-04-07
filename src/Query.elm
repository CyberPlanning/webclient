module Query exposing (..)

import Http exposing (Header, Body, Request, Error)
import Json.Encode as Encode
import Json.Decode as Decode


import Types exposing (decodeQuery, Query)
import Msg exposing ( Msg( GraphQlMsg ) )
import Config


eventsApiQuery: String
eventsApiQuery =
    "query day_planning($collection:String!,$grs:[String],$to:DateTime!,$from:DateTime!){planning(collection:$collection,affiliationGroups:$grs,toDate:$to,fromDate:$from){events{title startDate endDate classrooms teachers groups eventId}}}"


type alias Params =
    { from: String
    , to: String
    , grs: List String
    , collection: String
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


authorizationHeader: String -> Header
authorizationHeader =
    Http.header "Authorization"


requestAPI: (Result Error Query -> Msg) -> Request Query -> Cmd Msg
requestAPI =
    Http.send


requestBody: String -> Params -> Body
requestBody queryString { from, to, grs, collection } =
    let
        var =
            Encode.object
                [ ("from", Encode.string from)
                , ("to", Encode.string to)
                , ("grs", Encode.list (List.map Encode.string grs) )
                , ("collection", Encode.string collection)
                ]
    in
        Encode.object
            [ ("query", Encode.string queryString )
            , ("variables", var)
            ]
        |> Http.jsonBody


sendRequest : String -> String -> List String -> Cmd Msg
sendRequest from to groups =
    { from = from
    , to = to
    , grs = groups
    , collection = "planning_cyber"
    }
    |> requestBody eventsApiQuery
    |> post Config.apiUrl []
    |> requestAPI GraphQlMsg
