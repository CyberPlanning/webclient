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
import Utils exposing (find, getGroup, groupId, toCalEvents, toCalEventsWithSource, toDatetime)



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
            ( { model | date = Just date, calendarState = Calendar.init timespan date }
            , createPlanningRequest date model.selectedGroups model.selectedCollection model.settings
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
                                |> Just

                        cmd =
                            Task.attempt (always Noop) (Browser.Dom.blur "select-group")
                    in
                    ( { model | data = allEvents, loading = False, error = Nothing }, cmd )

                Err err ->
                    ( { model | error = Just err, loading = False }, Cmd.none )

        SetGroup idString ->
            let
                id =
                    String.toInt idString
                        |> Maybe.withDefault 0

                groups =
                    getGroup id
                        |> List.singleton

                storage =
                    { groupId = id
                    , settings = model.settings
                    }

                ( load, action ) =
                    if (model.loading == False) && (model.loop == False) then
                        ( True, queryReload (createPlanningRequest model.calendarState.viewing groups model.selectedCollection model.settings) )

                    else
                        ( False, Cmd.none )
            in
            ( { model | selectedGroups = groups, loading = True, loop = True }, Cmd.batch [ Storage.save storage, action ] )

        SetGroups idsStrings ->
            let
                groups =
                    List.map (String.toInt >> Maybe.withDefault 0 >> getGroup) idsStrings

                storage =
                    { groupId = 0
                    , settings = model.settings
                    }

                ( load, action ) =
                    if (model.loading == False) && (model.loop == False) then
                        ( True, queryReload (createPlanningRequest model.calendarState.viewing groups model.selectedCollection model.settings) )

                    else
                        ( False, Cmd.none )
            in
            ( { model | selectedGroups = groups, loading = True, loop = True }, Cmd.batch [ Storage.save storage, action ] )

        Reload ->
            ( { model | loading = True, loop = True }, queryReload (createPlanningRequest model.calendarState.viewing model.selectedGroups model.selectedCollection model.settings) )

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

                storage =
                    -- { groupId = groupId model.selectedGroups
                    { groupId = 0
                    , settings = newSettings
                    }
            in
            ( { model | settings = newSettings }, Storage.save storage )

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

                storage =
                    -- { groupId = groupId calendarModel.selectedGroups
                    { groupId = 0
                    , settings = updatedSettings
                    }
            in
            ( { calendarModel | settings = updatedSettings }, Storage.save storage )

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

                storage =
                    -- { groupId = groupId model.selectedGroups
                    { groupId = 0
                    , settings = updatedSettings
                    }

                cmd =
                    Cmd.batch
                        [ createPlanningRequest model.calendarState.viewing model.selectedGroups model.selectedCollection updatedSettings
                        , Storage.save storage
                        ]
            in
            ( { model | loading = True, loop = True, settings = updatedSettings }, queryReload cmd )


createPlanningRequest : Posix -> List Group -> Collection -> Settings -> Cmd Msg
createPlanningRequest date groups collection settings =
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

        collectionName =
            case collection of
                Cyber ->
                    "CYBER"

                Info ->
                    "INFO"

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
                ( createPlanningRequest updatedCalendar.viewing model.selectedGroups model.selectedCollection model.settings
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


queryReload : Cmd.Cmd Msg -> Cmd.Cmd Msg
queryReload action =
    Cmd.batch
        [ action
        , Process.sleep (1 * 1000)
            |> Task.perform StopReloadIcon
        ]
