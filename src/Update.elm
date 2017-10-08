module Update exposing (..)

import Date
import Task
import Http exposing (Error)

import Model exposing (Model, allGroups)
import Types exposing (Query)

import FakeQuery exposing (createFakeQuery)


---- UPDATE ----


type Msg
    = GraphQlMsg (Result Error Query)
    | SetDate Date.Date
    | SetGroup String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetDate date ->
            ( { model | date = Just date }, createPLanningRequest date model.selectedGroup.slug)

        GraphQlMsg response ->
            ( { model | data = Just response, loading = False }, Cmd.none )

        SetGroup slug ->
            let
                group =
                    Maybe.withDefault { slug = "12", name = "Cyber1 TD2" } <| find (\x -> x.slug == slug) allGroups

                cmd =
                    if model.loading then
                        Cmd.none
                    else
                        case model.date of
                            Just date ->
                                createPLanningRequest date slug

                            Nothing ->
                                Cmd.none
                
            in
                ( { model | selectedGroup = group, loading = True }, cmd )


createPLanningRequest: Date.Date -> String -> Cmd Msg
createPLanningRequest date slug =
    -- sendRequest (toDatetime (Dateextra.add Dateextra.Month -7 date)) (toDatetime (Dateextra.add Dateextra.Month 7 date)) [ slug ]
    -- sendRequest (toDatetime date) (toDatetime (Dateextra.add Dateextra.Week 1 date)) [ slug ]
    Task.succeed (GraphQlMsg ( Ok createFakeQuery ) ) |> Task.perform identity


find : (a -> Bool) -> List a -> Maybe a
find predicate list =
    case list of
        [] ->
            Nothing

        first::rest ->
            if predicate first then
                Just first
            else
                find predicate rest
