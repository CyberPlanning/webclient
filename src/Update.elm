module Update exposing (..)

import Task
import Time
import Process
import Dom
import Date
import Date.Extra as Dateextra

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
                timespan = if model.size.width < 720 then
                                Day
                           else
                                Week
            in
                ( { model | date = Just date, calendarState = Calendar.init timespan date }
                , createPlanningRequest date model.selectedGroup.slug
                )

        GraphQlMsg response ->
            let
                query = Result.toMaybe response

                data = case query of
                    Just query ->
                        query.planning.events
                        |> toCalEvents
                        |> Just

                    _ ->
                        Nothing
            in
                ( { model | data = data, loading = False }, Task.attempt (always Noop) (Dom.blur "groupSelect"))
                -- ( { model | data = data, loading = False }, Cmd.none)

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

        ClickToday ->
            let
                date = model.date |> Maybe.withDefault (Date.fromTime 0)
                calendarState = model.calendarState
                newCalendarState = { calendarState | viewing = date }
            in
                ( { model | calendarState = newCalendarState }, Cmd.none )

        LoadGroup slug ->
            let
                group =
                    Maybe.withDefault { slug = "12", name = "Cyber1 TD2" } <| find (\x -> x.slug == slug) allGroups
            in
                ( { model | selectedGroup = group }, Task.perform SetDate Date.now )

        SavedGroup ok ->
            let
                cmd =
                    createPlanningRequest model.calendarState.viewing model.selectedGroup.slug

                timeout =
                    Process.sleep (1 * Time.second)
                    |> Task.perform StopReloadIcon

            in
                ( { model | loading = True, loop = True }, Cmd.batch [ cmd, timeout ])

        StopReloadIcon _ ->
            ( { model | loop = False }, Cmd.none )


createPlanningRequest: Date.Date -> String -> Cmd Msg
createPlanningRequest date slug =
    let
        monthBegin = Dateextra.floor Dateextra.Month date

        dateFrom = toDatetime (Dateextra.floor Dateextra.Monday monthBegin)

        dateTo = toDatetime (Dateextra.ceiling Dateextra.Month date)
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
    |> Debug.log "Distance"


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