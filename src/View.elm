module View exposing (..)

import Date
import Date.Extra as Dateextra
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, targetValue, onClick)
import Json.Decode as Json
import Color exposing (Color)

import Model exposing ( Model, Group, allGroups, toDatetime )
import Msg exposing ( Msg(..) )
import Types exposing (..)

import Swipe exposing ( onSwipe )

import Calendar.Calendar as Calendar
import Calendar.Event as CalEvent
import Calendar.Helpers exposing (colorToHex)

---- VIEW ----


view : Model -> Html Msg
view model =
    let
        datetime =
            case model.date of
                Just date ->
                    toDatetime date

                Nothing ->
                    "Nothing"

        events =
            model.data |> Maybe.withDefault []

        attrs = (Swipe.onSwipe SwipeEvent)
               ++
               [ class "main--container" ]

    in
        div attrs
            [ viewToolbar model.selectedGroup model.calendarState.viewing
            , div [ class "main--calendar" ]
                [ Html.map SetCalendarState (Calendar.view events model.calendarState)
                ]
            , viewTooltip model.calendarState.hover events
            ]


viewToolbar : Group -> Date.Date -> Html Msg
viewToolbar selected viewing =
    div [ class "main--toolbar" ]
        [ viewPagination
        , viewTitle viewing
        , select [ class "main--selector", on "change" <| Json.map SetGroup targetValue, value selected.slug ] (List.map optionGroup allGroups)
        -- , viewTimeSpanSelection timeSpan
        ]


viewTitle : Date.Date -> Html Msg
viewTitle viewing =
    div [ class "main--month-title", onClick ClickToday ]
        [ h2 [] [ text <| Dateextra.toFormattedString "MMMM yyyy" viewing ] ]


viewPagination : Html Msg
viewPagination =
    div [ class "main--paginators" ]
        [ button [ class "main--navigatiors-button", onClick PageBack ] [ text "back" ]
        , button [ class "main--navigatiors-button", onClick PageForward ] [ text "next" ]
        ]


-- viewTimeSpanSelection : TimeSpan -> Html Msg
-- viewTimeSpanSelection timeSpan =
--     div [ class "main--time-spans" ]
--         [ button [ class "main--button", onClick (ChangeTimeSpan Week) ] [ text "Week" ]
--         , button [ class "main--button", onClick (ChangeTimeSpan Day) ] [ text "Day" ]
--         ]


optionGroup: Group -> Html Msg
optionGroup group =
    option [ value group.slug ]
           [ text group.name ]


viewTooltip : Maybe String -> List CalEvent.Event -> Html Msg
viewTooltip selectedId events =
    let
        content = case selectedId of
            Just id ->
                List.filter (\e -> e.toId == id) events
                |> List.head
                |> viewTooltipContent

            _ ->
                []
    in
        div [ class "tooltip" ] content

viewTooltipContent : Maybe CalEvent.Event -> List (Html Msg)
viewTooltipContent event =
    case event of
        Just event ->
            [ div [ class "tooltip--event", (tooltipStyle event.color)]
                [ div [ class "tooltip--event-title" ] [ text event.title ]
                , div [ class "tooltip--event-sub" ] [ text <| String.join "," event.classrooms ]
                , div [ class "tooltip--event-sub" ] [ text <| String.join "," event.teachers ]
                , div [ class "tooltip--event-sub" ] [ text <| String.join "," event.groups ]
                ]
            ]
        _ ->
            []


tooltipStyle : Color -> Html.Attribute Msg
tooltipStyle color =
        style [ ("background-color", colorToHex color) ]