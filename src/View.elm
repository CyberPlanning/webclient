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
import Model exposing (Group, Model)
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
                model.data |> Maybe.withDefault []

        attrs =
            Swipe.onSwipe SwipeEvent
                ++ [ class "main--container" ]
                ++ Secret.classStyle model.secret

        currentEvent =
            if model.size.width < Config.minWeekWidth then
                model.calendarState.selected

            else
                model.calendarState.hover

        funThings =
            Secret.view model.secret

        container =
            div attrs
                [ viewToolbar model.selectedGroup model.calendarState.viewing (model.calendarState.timeSpan /= Day) model.loop
                , div [ class "main--calendar" ]
                    [ SideMenu.view model.selectedGroup model.calendarState.timeSpan model.settings
                    , Html.map SetCalendarState (Calendar.view events model.calendarState)
                    ]
                , viewMessage model
                , Tooltip.viewTooltip currentEvent model.calendarState.position events model.size
                , funThings
                ]
    in
    { title = "Planning - " ++ model.selectedGroup.name
    , body = [ container ]
    }


viewToolbar : Group -> Posix -> Bool -> Bool -> Html Msg
viewToolbar selected viewing all loop =
    div [ class "main--toolbar" ]
        [ viewPagination all loop
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
viewPagination all loop =
    let
        navigations =
            if all then
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


viewMessage : Model -> Html Msg
viewMessage model =
    let
        ( message, display ) =
            case model.error of
                Just err ->
                    ( errorMessage err, True )

                _ ->
                    if model.loading then
                        ( "Loading...", True )

                    else
                        ( "", False )
    in
    div
        [ class
            ("main--message "
                ++ (if display then
                        ""

                    else
                        "hidden"
                   )
            )
        ]
        [ text message
        ]


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
