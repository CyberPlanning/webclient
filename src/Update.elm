module Update exposing (update)

import Browser.Navigation as Nav
import Calendar.Calendar as Calendar
import Calendar.Msg as CalMsg exposing (TimeSpan(..))
import Config
import Cyberplanning.Cyberplanning as Cyberplanning
import Cyberplanning.Types exposing (RequestAction(..))
import Model exposing (Model)
import Msg exposing (Msg(..))
import MyTime
import Personnel.Personnel as Personnel
import Process
import Secret.Secret as Secret
import Storage
import Task
import Time
import Vendor.Swipe as Swipe
import Url
import Utils



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msgSource model =
    (case msgSource of
        Noop ->
            ( model, Cmd.none )

        SetDate date ->
            let
                timespan =
                    if model.size.width < Config.minWeekWidth then
                        Day

                    else
                        Week

                calendar =
                    Calendar.init timespan date

                ( planning, cmd ) =
                    Cyberplanning.request model.planningState calendar.viewing
                        |> updateWith SetPlanningState
            in
            ( { model | date = Just date, calendarState = calendar, planningState = planning }
            , cmd
            )

        Reload ->
            let
                ( planning, action ) =
                    Cyberplanning.request model.planningState model.calendarState.viewing
            in
            ( { model | planningState = planning }, Cmd.map SetPlanningState action )

        SetCalendarState calendarMsg ->
            calendarAction model calendarMsg

        SetPersonnelState personnelMsg ->
            if Config.enablePersonnelCal then
                personnelAction model personnelMsg
            else
                ( model , Cmd.none )

        SetPlanningState personnelMsg ->
            let
                ( planning, action ) =
                    Cyberplanning.update personnelMsg model.planningState

                ( planning2, cmd ) =
                    case action of
                        RequestApi ->
                            Cyberplanning.request planning model.calendarState.viewing
                                |> updateWith SetPlanningState

                        SaveState ->
                            let
                                url = model.url
                                newUrl =
                                    { url | fragment = Just (Utils.generateFragment planning.selectedGroups ) }
                                    |> Url.toString
                                    |> Nav.replaceUrl model.navKey 
                            in
                            ( planning, Cmd.batch [ Storage.saveState ( "cyberplanning", Cyberplanning.storeState planning) , newUrl ] )

                        NoAction ->
                            ( planning, Cmd.none )
            in
            ( { model | planningState = planning2 }, cmd )

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

                secret =
                    if Config.enableEasterEgg then
                        Secret.update code model.secret
                    else
                        model.secret

                updatedModel =
                    { calendarModel | secret = secret }
            in
            ( updatedModel, cmd )

        SwipeEvent msg ->
            let
                updatedSwipe =
                    Swipe.update msg model.swipe

                action =
                    case Swipe.hasSwiped updatedSwipe 70 of
                        Just Swipe.Left ->
                            Task.succeed (SetCalendarState CalMsg.PageForward)
                                |> Task.perform identity

                        Just Swipe.Right ->
                            Task.succeed (SetCalendarState CalMsg.PageBack)
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
            ( { model | menuOpened = not model.menuOpened }, Cmd.none )

        ChangeMode mode ->
            calendarAction model (CalMsg.ChangeTimeSpan mode)

        UrlChanged url ->
            ( { model | url = url }, Cmd.none )
    )
        |> queryReload model


calendarAction : Model -> CalMsg.Msg -> ( Model, Cmd Msg )
calendarAction model calMsg =
    let
        updatedCalendar =
            Calendar.update calMsg model.calendarState

        ( planning, cmd ) =
            if MyTime.toMonth updatedCalendar.viewing /= MyTime.toMonth model.calendarState.viewing then
                Cyberplanning.request model.planningState updatedCalendar.viewing
                    |> updateWith SetPlanningState

            else
                ( model.planningState, Cmd.none )

        updatedCalWithJourFerie =
            if MyTime.toYear updatedCalendar.viewing /= MyTime.toYear model.calendarState.viewing then
                Calendar.init updatedCalendar.timeSpan updatedCalendar.viewing

            else
                updatedCalendar
    in
    ( { model | calendarState = updatedCalWithJourFerie, planningState = planning }, cmd )


personnelAction : Model -> Personnel.Msg -> ( Model, Cmd Msg )
personnelAction model personnelMsg =
    let
        ( personnel, action ) =
            Personnel.update personnelMsg model.personnelState

        cmd =
            Cmd.batch
                [ Cmd.map SetPersonnelState action
                , Storage.saveState ( "personnel", Personnel.storeState personnel )
                ]
    in
    ( { model | personnelState = personnel }, cmd )



updateWith : (subMsg -> Msg) -> ( subModel, Cmd subMsg ) -> ( subModel, Cmd Msg )
updateWith toMsg ( subModel, subCmd ) =
    ( subModel
    , Cmd.map toMsg subCmd
    )


queryReload : Model -> ( Model, Cmd.Cmd Msg ) -> ( Model, Cmd.Cmd Msg )
queryReload previousModel ( model, action ) =
    if model.planningState.status == Cyberplanning.Types.Loading && previousModel.planningState.status /= Cyberplanning.Types.Loading then
        ( { model | loop = True }
        , Cmd.batch
            [ action
            , Process.sleep (1 * 1000)
                |> Task.perform StopReloadIcon
            ]
        )

    else
        ( model, action )
