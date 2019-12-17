module Cyberplanning.PlanningRequest exposing (createPlanningRequest, maybeCreatePlanningRequest)

import Cyberplanning.Query exposing (Params, sendRequest)
import Cyberplanning.Types exposing (Collection(..), Group, InternalMsg, Settings)
import Cyberplanning.Utils exposing (toDatetime)
import MyTime
import Time exposing (Posix)
import Time.Extra as TimeExtra


maybeCreatePlanningRequest : Posix -> List Group -> Settings -> Cmd InternalMsg
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
                        |> sendRequest

                Info ->
                    createPlanningRequest date "INFO" slugs settings
                        |> sendRequest

        Nothing ->
            Cmd.none


createPlanningRequest : Posix -> String -> List String -> Settings -> Params
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
