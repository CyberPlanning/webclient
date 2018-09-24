module View exposing (errorMessage, optionGroup, reloadButton, view, viewMessage, viewPagination, viewSelector, viewTitle, viewToolbar)

import Browser exposing (Document)
import Calendar.Calendar as Calendar
import Calendar.Msg exposing (TimeSpan(..))
import Config exposing (allGroups)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, targetValue)
import Http
import Json.Decode as Json
import Model exposing (Group, Model, toDatetime)
import Msg exposing (Msg(..))
import Secret
import Secret.Help
import Swipe exposing (onSwipe)
import Time exposing (Month(..), Posix)
import TimeZone exposing (europe__paris)
import Tooltip



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

        funThings =
            Secret.view model.secret

        container =
            div attrs
                [ viewToolbar model.selectedGroup model.calendarState.viewing (model.calendarState.timeSpan == Week) model.loop
                , div [ class "main--calendar" ]
                    [ Html.map SetCalendarState (Calendar.view events model.calendarState)
                    ]
                , viewMessage model
                , Tooltip.viewTooltip model.calendarState.hover events
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
        , viewSelector selected

        -- , viewTimeSpanSelection timeSpan
        ]


viewTitle : Posix -> Html Msg
viewTitle viewing =
    div [ class "main--month-title" ]
        [ h2 [] [ text <| formatDateTitle viewing ] ]



-- "MMMM yyyy"


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
        btns =
            if all then
                [ button [ class "main--navigatiors-button", onClick PageBack ] [ text "back" ]
                , button [ class "main--navigatiors-button", onClick PageForward ] [ text "next" ]
                ]

            else
                []
    in
    div [ class "main--paginators" ]
        (btns
            ++ [ button [ class "main--navigatiors-button", onClick ClickToday ] [ text "today" ]
               , reloadButton loop
               ]
        )


viewSelector : Group -> Html Msg
viewSelector selected =
    div [ class "main--selector" ]
        [ select
            [ class "main--selector-select"
            , id "groupSelect"
            , on "change" <| Json.map SetGroup targetValue
            , value selected.slug
            , multiple False
            ]
            (List.map optionGroup allGroups)
        ]


optionGroup : Group -> Html Msg
optionGroup group =
    option [ value group.slug ]
        [ text group.name ]


reloadButton : Bool -> Html Msg
reloadButton loop =
    button
        [ classList
            [ ( "main--navigatiors-button", True )
            , ( "main--navigatiors-reload", True )
            , ( "loop", loop )
            ]
        , style "font-size" "1.2em"
        , onClick (SavedGroup "ok")
        ]
        [ span [] [ text "⟳" ]
        ]


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
