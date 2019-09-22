module Update exposing (calendarAction, createPlanningRequest, update)

import Browser.Dom
import Calendar.Calendar as Calendar
import Calendar.Msg as CalMsg exposing (TimeSpan(..))
import Config exposing (allGroups, firstGroup)
import Model exposing (Collection(..), CustomEvent(..), Group, Model, Settings)
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
import Utils exposing (find, getGroup, toCalEvents, toCalEventsWithSource, toDatetime)



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

                    else if model.settings.allWeek then
                        AllWeek

                    else
                        Week
            in
            ( { model | date = Just date, calendarState = Calendar.init timespan date (List.length model.selectedGroups) }
            , createPlanningRequest date model.selectedGroups model.settings
            )

        GraphQlMsg response ->
            case response of
                Ok query ->
                    let
                        cyberEvents =
                            query.planning.events
                                |> toCalEvents model.selectedGroups

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

                        newCalendarState =
                            model.calendarState
                                |> Calendar.update (CalMsg.SetColumns (List.length model.selectedGroups))

                        cmd =
                            Cmd.batch
                                [ Storage.saveEvents query
                                , Task.attempt (always Noop) (Browser.Dom.blur "select-group")
                                ]
                    in
                    ( { model | data = allEvents, loading = False, error = Nothing, calendarState = newCalendarState }, cmd )

                Err err ->
                    ( { model | error = Just err, loading = False }, Cmd.none )

        SetGroups idsStrings ->
            let
                groupsIds =
                    List.map (String.toInt >> Maybe.withDefault 0) idsStrings

                groups =
                    List.map getGroup groupsIds

                action =
                    createPlanningRequest model.calendarState.viewing groups model.settings
                        |> queryReload
            in
            ( { model | selectedGroups = groups, loading = True, loop = True }, Cmd.batch [ Storage.saveGroups groupsIds, action ] )

        Reload ->
            ( { model | loading = True, loop = True }, queryReload (createPlanningRequest model.calendarState.viewing model.selectedGroups model.settings) )

        SetCalendarState calendarMsg ->
            calendarAction model calendarMsg

        PageForward ->
            calendarAction model CalMsg.PageForward

        PageBack ->
            calendarAction model CalMsg.PageBack

        WindowSize view ->
            ( { model | size = { width = floor view.viewport.width, height = floor view.viewport.height } }, Task.perform SetDate Time.now )

        KeyDown code ->
            let
                ( calendarModel, cmd ) =
                    case code of
                        39 ->
                            calendarAction model CalMsg.PageForward

                        37 ->
                            calendarAction model CalMsg.PageBack

                        _ ->
                            ( model, Cmd.none )

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

        StopReloadIcon _ ->
            ( { model | loop = False }, Cmd.none )

        ToggleMenu ->
            let
                s =
                    model.settings

                newSettings =
                    { s | menuOpened = not s.menuOpened }
            in
            ( { model | settings = newSettings }, Storage.saveSettings newSettings )

        ChangeMode mode ->
            let
                ( calendarModel, _ ) =
                    calendarAction model (CalMsg.ChangeTimeSpan mode)

                allWeek =
                    if mode == AllWeek then
                        True

                    else
                        False

                s =
                    model.settings

                updatedSettings =
                    { s | allWeek = allWeek }
            in
            ( { calendarModel | settings = updatedSettings }, Storage.saveSettings updatedSettings )

        CheckEvents type_ checked ->
            let
                s =
                    model.settings

                updatedSettings =
                    case type_ of
                        Hack2g2 ->
                            { s | showHack2g2 = checked }

                        Custom ->
                            { s | showCustom = checked }

                cmd =
                    Cmd.batch
                        [ createPlanningRequest model.calendarState.viewing model.selectedGroups updatedSettings
                        , Storage.saveSettings updatedSettings
                        ]
            in
            ( { model | loading = True, loop = True, settings = updatedSettings }, queryReload cmd )


createPlanningRequest : Posix -> List Group -> Settings -> Cmd Msg
createPlanningRequest date groups settings =
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

        maybeFirstGrp =
            List.head groups

        collectionName =
            case maybeFirstGrp of
                Just collec ->
                    case collec.collection of
                        Cyber ->
                            "CYBER"

                        Info ->
                            "INFO"

                Nothing ->
                    "CYBER"

        groupsSlugs =
            List.map .slug groups
    in
    sendRequest dateFrom dateTo groupsSlugs settings collectionName


calendarAction : Model -> CalMsg.Msg -> ( Model, Cmd Msg )
calendarAction model calMsg =
    let
        updatedCalendar =
            Calendar.update calMsg model.calendarState

        ( cmd, loading ) =
            if Time.toMonth europe__paris updatedCalendar.viewing /= Time.toMonth europe__paris model.calendarState.viewing then
                ( createPlanningRequest updatedCalendar.viewing model.selectedGroups model.settings
                , True
                )

            else
                ( Cmd.none, False )

        updatedCalWithJourFerie =
            if Time.toYear europe__paris updatedCalendar.viewing /= Time.toYear europe__paris model.calendarState.viewing then
                Calendar.init updatedCalendar.timeSpan updatedCalendar.viewing updatedCalendar.columns

            else
                updatedCalendar
    in
    ( { model | calendarState = updatedCalWithJourFerie, loading = loading }, cmd )


queryReload : Cmd.Cmd Msg -> Cmd.Cmd Msg
queryReload action =
    Cmd.batch
        [ action
        , Process.sleep (1 * 1000)
            |> Task.perform StopReloadIcon
        ]
