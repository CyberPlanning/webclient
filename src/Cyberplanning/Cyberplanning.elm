module Cyberplanning.Cyberplanning exposing (Msg, State, initState, request, restoreState, storeState, update, view)

import Calendar.Event as CalEvent
import Config exposing (allGroups, firstGroup)
import Cyberplanning.PlanningRequest exposing (maybeCreatePlanningRequest)
import Cyberplanning.Storage exposing (decodeState, encodeState)
import Cyberplanning.Types exposing (CustomEvent(..), Event, FetchStatus(..), Group, InternalMsg(..), InternalState, Query, RequestAction(..), Settings, defaultState)
import Cyberplanning.Utils exposing (toCalEvents, toCalEventsWithSource)
import Html exposing (Html, text)
import Http exposing (Error)
import Time exposing (Posix)



-- STATE


type alias State =
    InternalState


type alias Msg =
    InternalMsg


initState : State
initState =
    defaultState



-- UPDATE


update : Msg -> State -> ( State, RequestAction )
update msg state =
    case msg of
        Noop ->
            ( state, NoAction )

        CheckEvents type_ checked ->
            let
                s =
                    state.settings

                settings =
                    case type_ of
                        Hack2g2 ->
                            { s | showHack2g2 = checked }

                        Custom ->
                            { s | showCustom = checked }

                -- action =
                --     maybeCreatePlanningRequest model.calendarState.viewing model.selectedGroups settings
                --         |> queryReload
            in
            ( { state | status = Loading, settings = settings }, RequestApi )

        SetGroups idsStrings ->
            let
                groupsIds =
                    List.map (String.toInt >> Maybe.withDefault 0) idsStrings

                groups =
                    List.filter (\x -> List.member x.id groupsIds) allGroups

                -- action =
                --     maybeCreatePlanningRequest model.calendarState.viewing groups state.settings
                --         |> queryReload
            in
            ( { state | selectedGroups = groups, status = Normal }, RequestApi )

        GraphQlResult response ->
            case response of
                Ok query ->
                    let
                        cyberEvents =
                            query.planning.events
                                |> toCalEvents state.selectedGroups

                        hack2g2Events =
                            case query.hack2g2 of
                                Nothing ->
                                    []

                                Just p ->
                                    p.events
                                        |> toCalEventsWithSource "Hack2g2" "#00ff1d"

                        customEvents =
                            case query.custom of
                                Nothing ->
                                    []

                                Just p ->
                                    p.events
                                        |> toCalEventsWithSource "Custom" "#d82727"

                        allEvents =
                            cyberEvents
                                ++ hack2g2Events
                                ++ customEvents
                    in
                    ( { state | events = allEvents, status = Normal, groupsCount = List.length state.selectedGroups }, SaveState )

                Err err ->
                    ( { state | status = Error err }, NoAction )



-- VIEW


view : State -> Html Msg
view state =
    text ""



-- INTERFACE


request : State -> Posix -> ( State, Cmd Msg )
request state date =
    let
        reqAction =
            maybeCreatePlanningRequest date state.selectedGroups state.settings
    in
    ( { state | status = Loading }, reqAction )



-- STORAGE


storeState : State -> String
storeState =
    encodeState


restoreState : String -> State
restoreState =
    decodeState
