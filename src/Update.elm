module Update exposing (..)

import Task
import Time
import Process
import Dom
import Date
import Date.Extra as Dateextra
import Http exposing (Error)


import Storage
import Model exposing (Model, toDatetime, toCalEvents)
import Requests exposing (sendRequest)
import Msg exposing (Msg(..))
import Calendar.Msg
import Config exposing (allGroups)

import Calendar.Calendar as Calendar
import Calendar.Msg as CalMsg exposing (TimeSpan(..))

import Swipe

---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop -> ( model, Cmd.none )

        SetDate date ->
            let
                timespan = if model.size.width < Config.minWeekWidth then
                                Day
                           else
                                Week
            in
                ( { model | date = Just date, calendarState = Calendar.init timespan date }
                , createPlanningRequest date model.selectedGroup.slug
                )

        GraphQlMsg response ->
            case response of
                Ok query ->
                    let
                        data =
                            query.planning.events
                            |> toCalEvents
                            |> Just
                        
                    in
                        ( { model | data = data, loading = False, error = Nothing }, Task.attempt (always Noop) (Dom.blur "groupSelect") )

                Err err ->
                    ( { model | error = Just (Debug.log "Network" err), loading = False }, Cmd.none )

        SetGroup slug ->
            let
                group =
                    Maybe.withDefault { slug = "12", name = "Cyber1 TD2" } <| find (\x -> x.slug == slug) allGroups
            in
                ( { model | selectedGroup = group}, Storage.save slug )

        SetCalendarState calendarMsg ->
            let
                updatedCalendar =
                    Calendar.update calendarMsg model.calendarState

            in
                ( { model | calendarState = updatedCalendar }, Cmd.none )

        PageForward ->
            calendarMove model CalMsg.PageForward

        PageBack ->
            calendarMove model CalMsg.PageBack

        WindowSize size ->
            ( { model | size = size }, Storage.doload () )
            -- ( { model | size = size }, Task.perform SetDate Date.now)

        KeyDown code ->
            let
                cmd = case code of
                    39 ->
                        Task.succeed PageForward
                        |> Task.perform identity

                    37 ->
                        Task.succeed PageBack
                        |> Task.perform identity

                    _ ->
                        Cmd.none
            in
                ( model, cmd )

        SwipeEvent msg ->
            let
                updatedSwipe =
                    Swipe.update msg model.swipe

                action =
                    if (updatedSwipe.state == Swipe.SwipeEnd) && (distanceX updatedSwipe.c0 updatedSwipe.c1 > 70.0) then
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

            in
                ( {model | swipe = updatedSwipe}, action )

        ClickToday ->
            let
                date = model.date |> Maybe.withDefault (Date.fromTime 0)
                updatedCalendar = Calendar.init model.calendarState.timeSpan date
                    
                (cmd, loading) =
                    if (Date.month updatedCalendar.viewing) /= (Date.month model.calendarState.viewing) then
                        ( createPlanningRequest updatedCalendar.viewing model.selectedGroup.slug
                        , True
                        )
                    else
                        (Cmd.none, False)
            in
                ( { model | calendarState = updatedCalendar, loading = loading }, cmd )

        LoadGroup slug ->
            let
                group =
                    find (\x -> x.slug == slug) allGroups
                    |> Maybe.withDefault { slug = "12", name = "Cyber1 TD2" }
            in
                ( { model | selectedGroup = group }, Task.perform SetDate Date.now )

        SavedGroup ok ->
            let
                state =
                    if (model.loading == False) && (model.loop == False) then
                        ( { model | loading = True, loop = True }, Cmd.batch
                            [ createPlanningRequest model.calendarState.viewing model.selectedGroup.slug
                            , Process.sleep (1 * Time.second)
                                |> Task.perform StopReloadIcon
                            ]
                        )
                    else
                        ( model, Cmd.none )

            in
                state

        StopReloadIcon _ ->
            ( { model | loop = False }, Cmd.none )


createPlanningRequest: Date.Date -> String -> Cmd Msg
createPlanningRequest date slug =
    let
        monthBegin =  date

        dateFrom = 
            date
            |> Dateextra.floor Dateextra.Month
            |> Dateextra.floor Dateextra.Monday
            |> toDatetime

        dateTo = 
            date
            |> Dateextra.ceiling Dateextra.Month
            |> Dateextra.ceiling Dateextra.Sunday
            |> toDatetime
    in
        sendRequest dateFrom dateTo [ slug ]
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
    -- |> Debug.log "Distance"


calendarMove: Model -> CalMsg.Msg -> ( Model, Cmd Msg )
calendarMove model calMsg =
    let
        updatedCalendar =
            Calendar.update calMsg model.calendarState
            
        (cmd, loading) =
            if (Date.month updatedCalendar.viewing) /= (Date.month model.calendarState.viewing) then
                ( createPlanningRequest updatedCalendar.viewing model.selectedGroup.slug
                , True
                )
            else
                (Cmd.none, False)
    in
        ( { model | calendarState = updatedCalendar, loading = loading }, cmd )