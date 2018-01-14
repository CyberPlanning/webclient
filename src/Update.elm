module Update exposing (..)

import Date
import Date.Extra as Dateextra

import Model exposing (Model, allGroups, toDatetime)

import Requests exposing (sendRequest, Msg(..))


---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetDate date ->
            ( { model | date = Just date }, createPlanningRequest date model.selectedGroup.slug)

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
                                createPlanningRequest date slug

                            Nothing ->
                                Cmd.none
                
            in
                ( { model | selectedGroup = group, loading = True }, cmd )


createPlanningRequest: Date.Date -> String -> Cmd Msg
createPlanningRequest date slug =
    -- sendRequest (toDatetime (Dateextra.add Dateextra.Month -7 date)) (toDatetime (Dateextra.add Dateextra.Month 7 date)) [ slug ]
    sendRequest (toDatetime date) (toDatetime (Dateextra.add Dateextra.Week 1 date)) [ slug ]
    -- Task.succeed (GraphQlMsg ( Ok createFakeQuery ) ) |> Task.perform identity


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
