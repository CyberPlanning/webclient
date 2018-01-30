module Update exposing (..)

import Task
import Date
import Date.Extra as Dateextra

import Model exposing (Model, allGroups, toDatetime)
import Requests exposing (sendRequest)
import Msg exposing (Msg(..))
import Calendar.Msg

import Calendar.Calendar as Calendar
import Calendar.Msg as CalMsg exposing (TimeSpan(..))

import Swipe

---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetDate date ->
            let
                timespan = if model.size.width < 720 then
                                Day
                           else
                                Week
            in
                ( { model | date = Just date, calendarState = Calendar.init timespan date }
                , createPlanningRequest date model.selectedGroup.slug
                )

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

        SetCalendarState calendarMsg ->
            let
                updatedCalendar =
                    Calendar.update calendarMsg model.calendarState

            in
                ( { model | calendarState = updatedCalendar }, Cmd.none )

        PageForward ->
            let
                updatedCalendar =
                    Calendar.update CalMsg.PageForward model.calendarState

            in
                ( { model | calendarState = updatedCalendar }, Cmd.none )

        PageBack ->
            let
                updatedCalendar =
                    Calendar.update CalMsg.PageBack model.calendarState

            in
                ( { model | calendarState = updatedCalendar }, Cmd.none )


        WindowSize size ->
            ( { model | size = size }, Task.perform SetDate Date.now)

        KeyDown code ->
            let
                updatedCalendar =
                    if code == 37 then
                        Calendar.update CalMsg.PageBack model.calendarState
                    else if code == 39 then
                        Calendar.update CalMsg.PageForward model.calendarState
                    else
                        model.calendarState
            in
                ( { model | calendarState = updatedCalendar }, Cmd.none )

        SwipeEvent msg ->
            let
                updatedSwipe =
                    Swipe.update msg model.swipe

                action = if updatedSwipe.state == Swipe.SwipeEnd then
                    if distanceX updatedSwipe.c0 updatedSwipe.c1 > 70.0 then
                        case updatedSwipe.direction of 
                            Just Swipe.Left ->
                                Task.succeed PageForward
                                |> Task.perform identity

                            Just Swipe.Right ->
                                Task.succeed PageBack
                                |> Task.perform identity

                            _ ->
                                Cmd.none
                        
                        else
                            Cmd.none
                    else
                        Cmd.none

            in
                ( {model | swipe = updatedSwipe}, action )


createPlanningRequest: Date.Date -> String -> Cmd Msg
createPlanningRequest date slug =
    -- sendRequest (toDatetime (Dateextra.add Dateextra.Month -7 date)) (toDatetime (Dateextra.add Dateextra.Month 7 date)) [ slug ]
    sendRequest (toDatetime (Dateextra.floor Dateextra.Monday date)) (toDatetime (Dateextra.add Dateextra.Month 2 date)) [ slug ]
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


distanceX : Swipe.Coordinates -> Swipe.Coordinates -> Float
distanceX c0 c1 = 
    abs (c0.clientX - c1.clientX)
    |> Debug.log "Distance"