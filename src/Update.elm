module Update exposing (calendarAction, createPlanningRequest, find, update)

import Browser.Dom
import Calendar.Calendar as Calendar
import Calendar.Msg as CalMsg exposing (TimeSpan(..))
import Config exposing (allGroups)
import Model exposing (Model, toCalEvents, toDatetime)
import Msg exposing (Msg(..))
import Process
import Query exposing (sendRequest)
import Secret
import Storage
import Swipe
import Task
import Time exposing (Posix)
import Time.Extra as TimeExtra
import TimeZone exposing (europe__paris)



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
                        AllWeek
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
                (calendarModel, cmd) =
                    case code of
                        39 ->
                            calendarAction model CalMsg.PageForward

                        37 ->
                            calendarAction model CalMsg.PageBack

                        _ ->
                            (model, Cmd.none)

                updatedModel =
                    { calendarModel | secret = Secret.update code model.secret }
            in
            ( updatedModel, cmd )

        SwipeEvent msg ->
            let
                updatedSwipe =
                    Swipe.update msg model.swipe

                action =
                    case Swipe.hasSwiped updatedSwipe 70 of
                        Just Swipe.Left ->
                            Task.succeed PageForward
                                |> Task.perform identity

                        Just Swipe.Right ->
                            Task.succeed PageBack
                                |> Task.perform identity

                        _ ->
                            Cmd.none
            in
            ( { model | swipe = updatedSwipe }, action )

        ClickToday ->
            model.date
            |> Maybe.withDefault (Time.millisToPosix 0)
            |> CalMsg.ChangeViewing
            |> calendarAction model

        LoadGroup slug ->
            let
                group =
                    find (\x -> x.slug == slug) allGroups
                        |> Maybe.withDefault { slug = "12", name = "Cyber1 TD2" }
            in
            ( { model | selectedGroup = group }, Task.perform SetDate Time.now )

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

        ToggleMenu ->
            ( { model | menuOpened = not model.menuOpened }, Cmd.none )


createPlanningRequest : Posix -> String -> Cmd Msg
createPlanningRequest date slug =
    let
        dateFrom =
            date
                |> TimeExtra.floor TimeExtra.Month europe__paris
                |> TimeExtra.floor TimeExtra.Monday europe__paris
                |> toDatetime

        dateTo =
            date
                -- Fix issue : Event not loaded in October to November transition
                |> TimeExtra.add TimeExtra.Day 1 europe__paris
                |> TimeExtra.ceiling TimeExtra.Month europe__paris
                |> TimeExtra.ceiling TimeExtra.Sunday europe__paris
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


calendarAction : Model -> CalMsg.Msg -> ( Model, Cmd Msg )
calendarAction model calMsg =
    let
        updatedCalendar =
            Calendar.update calMsg model.calendarState

        ( cmd, loading ) =
            if Time.toMonth europe__paris updatedCalendar.viewing /= Time.toMonth europe__paris model.calendarState.viewing then
                ( createPlanningRequest updatedCalendar.viewing model.selectedGroup.slug
                , True
                )

            else
                ( Cmd.none, False )

        updatedCalWithJourFerie =
            if Time.toYear europe__paris updatedCalendar.viewing /= Time.toYear europe__paris model.calendarState.viewing then
                Calendar.init updatedCalendar.timeSpan updatedCalendar.viewing

            else
                updatedCalendar
    in
    ( { model | calendarState = updatedCalWithJourFerie, loading = loading }, cmd )
