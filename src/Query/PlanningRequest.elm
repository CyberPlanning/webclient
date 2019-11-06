module Query.PlanningRequest exposing (createPlanningRequest, maybeCreatePlanningRequest)

import Model exposing (Collection(..), CustomEvent(..), Group, Model, Settings)
import Msg exposing (Msg)
import MyTime
import Query.Query exposing (Params, sendRequest)
import Time exposing (Posix)
import Time.Extra as TimeExtra
import Utils exposing (toDatetime)


maybeCreatePlanningRequest : Posix -> List Group -> Settings -> Cmd Msg
maybeCreatePlanningRequest date groups settings =
    let
        maybeFirstGrp =
            List.head groups

        slugs =
            List.map .slug groups
    in
    case maybeFirstGrp of
        Just firstGroup ->
            case firstGroup.collection of
                Cyber ->
                    createPlanningRequest date "CYBER" slugs settings

                Info ->
                    createPlanningRequest date "INFO" slugs settings

        Nothing ->
            Cmd.none


createPlanningRequest : Posix -> String -> List String -> Settings -> Cmd Msg
createPlanningRequest date collectionName slugs settings =
    let
        dateFrom =
            date
                |> MyTime.floor TimeExtra.Month
                |> MyTime.floor TimeExtra.Monday
                |> toDatetime

        dateTo =
            date
                -- Fix issue : Event not loaded in October to November transition
                |> MyTime.add TimeExtra.Day 1
                |> MyTime.ceiling TimeExtra.Month
                |> MyTime.ceiling TimeExtra.Sunday
                |> toDatetime
    in
    { collec = collectionName
    , from = dateFrom
    , to = dateTo
    , grs = slugs
    , hack2g2 = settings.showHack2g2
    , custom = settings.showCustom
    }
        |> sendRequest
