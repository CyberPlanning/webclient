module Query exposing (..)

import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import GraphQL.Request.Builder.Variable exposing (VariableSpec, NonNull)

type alias Event =
    { title : String
    , startDate : String
    , endDate : String
    , classrooms : List String
    , teachers : List String
    , groups : List String
    }

type alias Planning =
    { events: List Event
    }

type alias DateTime = 
    String

eventsQuery : Document Query Planning { vars | date : String, gr : Maybe (List String) }
eventsQuery =
    let
        dateVar =
            Var.required "date" .date Var.datetime

        groupVar = 
            Var.optional "gr" .gr (Var.list Var.string) ["11"]

        event =
            object Event
                |> with (field "title" [] string)
                |> with (field "startDate" [] string)
                |> with (field "endDate" [] string)
                |> with (field "classrooms" [] (list string))
                |> with (field "teachers" [] (list string))
                |> with (field "groups" [] (list string))

        planning =
            object Planning
                |> with (field "events" [] (list event))

        queryRoot =
            extract
                (field "planning"
                    [ ( "fromDate", Arg.variable dateVar )
                    , ( "affiliationGroups", Arg.variable groupVar)
                    ]
                    planning
                )
    in
        queryDocument queryRoot

eventsRequest : Request Query Planning
eventsRequest =
    request { date = "2017-09-28", gr = Just ["12"] } eventsQuery