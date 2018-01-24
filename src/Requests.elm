module Requests exposing (..)

import GraphQl
import Json.Encode as Encode
import Json.Decode as Decode exposing (Decoder, field)
import Types exposing (Query, Event, decodeQuery)
import Date
import Http exposing (Error)


type Msg
    = GraphQlMsg (Result Error Query)
    | SetDate Date.Date
    | SetGroup String


planningRequest : GraphQl.Value GraphQl.Root
planningRequest =
  GraphQl.named "day_planning"
    [ GraphQl.field "planning"
      |> GraphQl.withArgument "fromDate" (GraphQl.variable "from")
      |> GraphQl.withArgument "toDate" (GraphQl.variable "to")
      |> GraphQl.withArgument "affiliationGroups" (GraphQl.variable "grs")
      |> GraphQl.withSelectors
        [ GraphQl.field "events"
          |> GraphQl.withSelectors
            [ GraphQl.field "title"
            , GraphQl.field "startDate"
            , GraphQl.field "endDate"
            , GraphQl.field "classrooms"
            , GraphQl.field "teachers"
            , GraphQl.field "groups"
            ]
        ]
    ]
    |> GraphQl.withVariable "from" "DateTime!"
    |> GraphQl.withVariable "to" "DateTime!"
    |> GraphQl.withVariable "grs" "[String]"


baseRequest : GraphQl.Value GraphQl.Root -> Decoder a -> GraphQl.Request a
baseRequest =
  GraphQl.query "http://cyberplanning.fr/graphql/"
  -- GraphQl.query "http://ensibs.planningiut.fr/graphql/"


sendRequest : String -> String -> List String -> Cmd Msg
sendRequest from to groups =
  baseRequest planningRequest decodeQuery
    |> GraphQl.addVariables [ ("from", Encode.string from)
                            , ("to", Encode.string to)
                            , ("grs", Encode.list (List.map Encode.string groups))
                            ]
    |> GraphQl.send GraphQlMsg