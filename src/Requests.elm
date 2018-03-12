module Requests exposing (..)

import GraphQl
import Json.Encode as Encode
import Json.Decode as Decode exposing (Decoder, field)
import Types exposing (Query, Event, decodeQuery)
import Msg exposing (Msg(..))


planningRequest : GraphQl.Value GraphQl.Root
planningRequest =
  GraphQl.named "day_planning"
    [ GraphQl.field "planning"
      |> GraphQl.withArgument "fromDate" (GraphQl.variable "from")
      |> GraphQl.withArgument "toDate" (GraphQl.variable "to")
      |> GraphQl.withArgument "affiliationGroups" (GraphQl.variable "grs")
      |> GraphQl.withArgument "collection" (GraphQl.variable "collection")
      |> GraphQl.withSelectors
        [ GraphQl.field "events"
          |> GraphQl.withSelectors
            [ GraphQl.field "title"
            , GraphQl.field "startDate"
            , GraphQl.field "endDate"
            , GraphQl.field "classrooms"
            , GraphQl.field "teachers"
            , GraphQl.field "groups"
            , GraphQl.field "eventId"
            ]
        ]
    ]
    |> GraphQl.withVariable "from" "DateTime!"
    |> GraphQl.withVariable "to" "DateTime!"
    |> GraphQl.withVariable "grs" "[String]"
    |> GraphQl.withVariable "collection" "String!"


baseRequest : GraphQl.Value GraphQl.Root -> Decoder a -> GraphQl.Request a
baseRequest =
  GraphQl.query "https://cyberplanning.fr/graphql/"
  -- GraphQl.query "http://ensibs.planningiut.fr/graphql/"


sendRequest : String -> String -> List String -> Cmd Msg
sendRequest from to groups =
  baseRequest planningRequest decodeQuery
    |> GraphQl.addVariables [ ("from", Encode.string from)
                            , ("to", Encode.string to)
                            , ("grs", Encode.list (List.map Encode.string groups))
                            , ("collection", Encode.string "planning_cyber")
                            ]
    |> GraphQl.send GraphQlMsg