module View exposing (view)

import Browser exposing (Document)
import Calendar.Calendar as Calendar
import Calendar.Msg exposing (TimeSpan(..))
import Config
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, targetValue)
import Http
import Json.Decode as Json
import Model exposing (FetchStatus(..), Group, Model)
import Msg exposing (Msg(..))
import Secret
import Secret.Help
import SideMenu
import Swipe exposing (onSwipe)
import Time exposing (Month(..), Posix)
import TimeZone exposing (europe__paris)
import Tooltip
import Utils exposing (toDatetime)



---- VIEW ----


view : Model -> Document Msg
view model =
    let
        events =
            if Secret.isHelpActivated model.secret then
                Secret.Help.helpEvents model.calendarState.viewing

            else
                model.data

        attrs =
            Swipe.onSwipe SwipeEvent
                ++ [ class "main--container" ]
                ++ Secret.classStyle model.secret

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
            Secret.view model.secret

        fetchStatus =
            if model.loading then
                Loading

            else
                case model.error of
                    Just err ->
                        Error err

                    Nothing ->
                        None

        container =
            div attrs
                [ viewToolbar model.calendarState.viewing (model.calendarState.timeSpan /= Day) model.loop fetchStatus
                , div [ class "main--calendar" ]
                    [ SideMenu.view model.selectedGroups model.calendarState.timeSpan model.settings
                    , Html.map SetCalendarState (Calendar.view events model.calendarState)
                    ]
                , Tooltip.viewTooltip currentEvent model.calendarState.position model.size
                , funThings
                ]

        names =
            List.map .name model.selectedGroups
                |> String.join ", "
    in
    { title = "Planning - " ++ names
    , body = [ container ]
    }


viewToolbar : Posix -> Bool -> Bool -> FetchStatus -> Html Msg
viewToolbar viewing displayArrows loop fetchStatus =
    div [ class "main--toolbar" ]
        [ viewPagination displayArrows loop
        , viewMessage fetchStatus
        , viewTitle viewing
        ]


viewTitle : Posix -> Html Msg
viewTitle viewing =
    div [ class "main--month-title" ]
        [ h2 [] [ text <| formatDateTitle viewing ] ]


formatDateTitle : Posix -> String
formatDateTitle date =
    let
        month =
            Time.toMonth europe__paris date

        monthName =
            case month of
                Jan ->
                    "Janvier"

                Feb ->
                    "Février"

                Mar ->
                    "Mars"

                Apr ->
                    "Avril"

                May ->
                    "Mai"

                Jun ->
                    "Juin"

                Jul ->
                    "Juillet"

                Aug ->
                    "Août"

                Sep ->
                    "Septembre"

                Oct ->
                    "Octobre"

                Nov ->
                    "Novembre"

                Dec ->
                    "Décembre"

        year =
            Time.toYear europe__paris date
                |> String.fromInt
    in
    monthName ++ " " ++ year


viewPagination : Bool -> Bool -> Html Msg
viewPagination displayArrows loop =
    let
        navigations =
            if displayArrows then
                [ navButton
                    [ class "main--navigatiors-button", onClick PageBack, attribute "aria-label" "Previous Page" ]
                    [ i [ class "icon-left" ] []
                    ]
                , navButton
                    [ class "main--navigatiors-button", onClick PageForward, attribute "aria-label" "Next Page" ]
                    [ i [ class "icon-right" ] []
                    ]
                ]

            else
                []
    in
    div [ class "main--paginators" ]
        (viewMenuButton
            :: navigations
            ++ [ navButton [ class "main--navigatiors-today", onClick ClickToday, attribute "aria-label" "Today" ] [ text "aujourd'hui" ]
               , reloadButton loop
               ]
        )


reloadButton : Bool -> Html Msg
reloadButton loop =
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
    div
        [ class "main--navigatiors-action" ]
        [ button attr content ]


viewMessage : FetchStatus -> Html Msg
viewMessage fetchStatus =
    let
        content =
            case fetchStatus of
                Loading ->
                    [ span [] [ text "Loading" ] ]

                Error err ->
                    [ i [ class "icon-warn", style "color" "#f9f961" ] [], span [ style "color" "#f9f961" ] [ errorMessage err |> text ] ]

                None ->
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
