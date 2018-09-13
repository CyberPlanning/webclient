module Update exposing (calendarAction, createPlanningRequest, distanceX, find, update)

import Browser.Dom
import Calendar.Calendar as Calendar
import Calendar.Msg as CalMsg exposing (TimeSpan(..))
import Config exposing (allGroups)
import Date
import Model exposing (Model, toCalEvents, toDatetime)
import Msg exposing (Msg(..))
import Process
import Query exposing (sendRequest)
import Secret
import Storage
import Swipe
import Task



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msgSource model =
    case msgSource of
        Noop ->
            ( model, Cmd.none )

        SetDate date ->
            let
                timespan =
                    if model.size.width < Config.minWeekWidth then
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
                    ( { model | data = data, loading = False, error = Nothing }, Task.attempt (always Noop) (Browser.Dom.blur "groupSelect") )

                Err err ->
                    ( { model | error = Just err, loading = False }, Cmd.none )

        SetGroup slug ->
            let
                group =
                    find (\x -> x.slug == slug) allGroups
                        |> Maybe.withDefault { slug = "12", name = "Cyber1 TD2" }
            in
            ( { model | selectedGroup = group }, Storage.save slug )

        SetCalendarState calendarMsg ->
            let
                updatedCalendar =
                    Calendar.update calendarMsg model.calendarState
            in
            ( { model | calendarState = updatedCalendar }, Cmd.none )

        PageForward ->
            calendarAction model CalMsg.PageForward

        PageBack ->
            calendarAction model CalMsg.PageBack

        WindowSize view ->
            ( { model | size = { width = floor view.viewport.width, height = floor view.viewport.height } }, Storage.doload () )

        KeyDown code ->
            let
                cmd =
                    case code of
                        39 ->
                            Task.succeed PageForward
                                |> Task.perform identity

                        37 ->
                            Task.succeed PageBack
                                |> Task.perform identity

                        _ ->
                            Cmd.none

                updatedModel =
                    { model | secret = Secret.update code model.secret }
            in
            ( updatedModel, cmd )

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
            ( { model | swipe = updatedSwipe }, action )

        ClickToday ->
            let
                date =
                    model.date |> Maybe.withDefault (Date.fromOrdinalDate 0 0)
            in
            calendarAction model (CalMsg.ChangeViewing date)

        LoadGroup slug ->
            let
                group =
                    find (\x -> x.slug == slug) allGroups
                        |> Maybe.withDefault { slug = "12", name = "Cyber1 TD2" }
            in
            ( { model | selectedGroup = group }, Task.perform SetDate Date.today )

        SavedGroup ok ->
            let
                state =
                    if (model.loading == False) && (model.loop == False) then
                        ( { model | loading = True, loop = True }
                        , Cmd.batch
                            [ createPlanningRequest model.calendarState.viewing model.selectedGroup.slug
                            , Process.sleep (1 * 1000)
                                |> Task.perform StopReloadIcon
                            ]
                        )

                    else
                        ( model, Cmd.none )
            in
            state

        StopReloadIcon _ ->
            ( { model | loop = False }, Cmd.none )


createPlanningRequest : Date.Date -> String -> Cmd Msg
createPlanningRequest date slug =
    let
        dateFrom =
            date
                |> Date.floor Date.Month
                |> Date.floor Date.Monday
                |> toDatetime

        dateTo =
            date
                -- Fix issue : Event not loaded in October to November transition
                |> Date.add Date.Days 1
                |> Date.ceiling Date.Month
                |> Date.ceiling Date.Sunday
                |> toDatetime
    in
    sendRequest dateFrom dateTo [ slug ]


find : (a -> Bool) -> List a -> Maybe a
find predicate list =
    case list of
        [] ->
            Nothing

        first :: rest ->
            if predicate first then
                Just first

            else
                find predicate rest


distanceX : Swipe.Coordinates -> Swipe.Coordinates -> Float
distanceX c0 c1 =
    abs (c0.clientX - c1.clientX)


calendarAction : Model -> CalMsg.Msg -> ( Model, Cmd Msg )
calendarAction model calMsg =
    let
        updatedCalendar =
            Calendar.update calMsg model.calendarState

        ( cmd, loading ) =
            if Date.month updatedCalendar.viewing /= Date.month model.calendarState.viewing then
                ( createPlanningRequest updatedCalendar.viewing model.selectedGroup.slug
                , True
                )

            else
                ( Cmd.none, False )

        updatedCalWithJourFerie =
            if Date.year updatedCalendar.viewing /= Date.year model.calendarState.viewing then
                Calendar.init updatedCalendar.timeSpan updatedCalendar.viewing

            else
                updatedCalendar
    in
    ( { model | calendarState = updatedCalWithJourFerie, loading = loading }, cmd )
