module View.View exposing (view)

import Browser exposing (Document)
import Calendar.Calendar as Calendar
import Calendar.Msg exposing (TimeSpan(..))
import Config
import Cyberplanning.Types exposing (FetchStatus(..), Group)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, targetValue)
import Http
import Model exposing (Model)
import Msg exposing (Msg(..))
import MyTime
import Personnel.Personnel as Personnel
import Secret.Help
import Secret.Secret
import Time exposing (Month(..), Posix)
import Vendor.Swipe exposing (onSwipe)
import View.SideMenu as SideMenu
import View.Tooltip as Tooltip



---- VIEW ----


view : Model -> Document Msg
view model =
    let
        events =
            if Secret.Secret.isHelpActivated model.secret then
                Secret.Help.helpEvents model.calendarState.viewing

            else
                model.planningState.events ++ Personnel.getEvents model.personnelState

        attrs =
            onSwipe SwipeEvent
                ++ [ class "main--container" ]
                ++ Secret.Secret.classStyle model.secret

        currentEventId =
            if model.size.width < Config.minWeekWidth then
                model.calendarState.selected

            else
                model.calendarState.hover

        currentEvent =
            case currentEventId of
                Just id ->
                    List.filter (\e -> e.toId == id) events
                        |> List.head

                _ ->
                    Nothing

        funThings =
            Secret.Secret.view model.secret

        container =
            div attrs
                [ viewToolbar model.calendarState.viewing (model.calendarState.timeSpan /= Day) model.loop model.planningState.status
                , div [ class "main--calendar" ]
                    [ SideMenu.view model
                    , Html.map SetCalendarState (Calendar.view events model.planningState.groupsCount model.calendarState)
                    ]
                , Tooltip.viewTooltip currentEvent model.calendarState.position model.size
                , funThings
                ]

        names =
            List.map .name model.planningState.selectedGroups
                |> String.join ", "
    in
    { title = "Planning - " ++ names
    , body = [ container ]
    }


viewToolbar : Posix -> Bool -> Bool -> FetchStatus -> Html Msg
viewToolbar viewing displayArrows loop fetchStatus =
    let
        navigations =
            if displayArrows then
                [ viewArrowButton "icon-left" "Previous Page" (SetCalendarState Calendar.Msg.PageBack)
                , viewArrowButton "icon-right" "Next Page" (SetCalendarState Calendar.Msg.PageForward)
                ]

            else
                []
    in
    div [ class "main--toolbar" ]
        (viewMenuButton
            :: navigations
            ++ [ viewTodayButton
               , viewTodayIconButton
               , viewTitle viewing
               , viewMessage fetchStatus
               , viewReloadButton loop
               ]
        )


viewTitle : Posix -> Html Msg
viewTitle viewing =
    div [ class "main--month-title" ]
        [ h2 [] [ text <| formatDateTitle viewing ] ]


formatDateTitle : Posix -> String
formatDateTitle date =
    let
        monthName =
            MyTime.toMonth date
                |> MyTime.monthToString

        year =
            MyTime.toYear date
                |> String.fromInt
    in
    monthName ++ " " ++ year


viewArrowButton : String -> String -> Msg -> Html Msg
viewArrowButton classname label msg =
    navButton
        [ class "main--navigatiors-button", onClick msg, attribute "aria-label" label ]
        [ i [ class classname ] [] ]


viewTodayButton : Html Msg
viewTodayButton =
    navButton [ class "main--navigatiors-today", onClick ClickToday, attribute "aria-label" "Today" ] [ text "aujourd'hui" ]


viewTodayIconButton : Html Msg
viewTodayIconButton =
    navButton
        [ class "main--navigatiors-todayicon", onClick ClickToday, attribute "aria-label" "Today" ]
        [ i [ class "icon-today" ] [] ]


viewReloadButton : Bool -> Html Msg
viewReloadButton loop =
    navButton
        [ classList
            [ ( "main--navigatiors-button", True )
            , ( "main--navigatiors-reload", True )
            , ( "loop", loop )
            ]
        , onClick Reload
        , attribute "aria-label" "Reload"
        ]
        [ i [ class "icon-reload" ] []
        ]


viewMenuButton : Html Msg
viewMenuButton =
    navButton
        [ class "main--navigatiors-button", onClick ToggleMenu, attribute "aria-label" "Toggle Menu" ]
        [ i [ class "icon-menu" ] []
        ]


navButton : List (Attribute msg) -> List (Html msg) -> Html msg
navButton attr content =
    -- div
    --     [ class "main--navigatiors-action" ]
    --     [ button attr content ]
    button attr content


viewMessage : FetchStatus -> Html Msg
viewMessage fetchStatus =
    let
        content =
            case fetchStatus of
                Loading ->
                    [ span [] [ text "Loading" ] ]

                Error err ->
                    [ i [ class "icon-wifi", style "color" "#f9f961" ] [], span [ style "color" "#f9f961" ] [ errorMessage err |> text ] ]

                Normal ->
                    [ span [] [ text "" ] ]
    in
    div [ class "main--status" ] content


errorMessage : Http.Error -> String
errorMessage error =
    case error of
        Http.BadUrl _ ->
            "BadUrl"

        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "Network Error"

        Http.BadStatus _ ->
            "BadStatus"

        Http.BadPayload _ _ ->
            "BadPayload"
