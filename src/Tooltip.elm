module Tooltip exposing (viewTooltip)

import Calendar.Event as CalEvent
import Date exposing (Date)
import Html exposing (..)
import Html.Attributes exposing (..)
import Msg exposing (Msg(..))


viewTooltip : Maybe String -> List CalEvent.Event -> Html Msg
viewTooltip selectedId events =
    let
        content =
            case selectedId of
                Just id ->
                    List.filter (\e -> e.toId == id) events
                        |> List.head
                        |> viewTooltipContent

                _ ->
                    []
    in
    div [ class "tooltip" ] content


viewTooltipContent : Maybe CalEvent.Event -> List (Html Msg)
viewTooltipContent maybeEvent =
    case maybeEvent of
        Just event ->
            [ div [ class "tooltip--event", tooltipStyle event.color ]
                ([ div [ class "tooltip--event-title" ] [ text event.title ]
                 , div [ classList [ ( "tooltip--event-sub", True ), ( "tooltip--event-hours", True ) ] ] [ viewHour event ]
                 ]
                    ++ showIfNotEmpty [ String.join "," event.classrooms, String.join "," event.teachers, String.join "," event.groups ]
                )
            ]

        _ ->
            []


showIfNotEmpty : List String -> List (Html Msg)
showIfNotEmpty data =
    List.filter (\e -> String.isEmpty e == False) data
        |> List.map (\e -> div [ class "tooltip--event-sub" ] [ text e ])


tooltipStyle : String -> Html.Attribute Msg
tooltipStyle color =
    style "background-color" color


viewHour : CalEvent.Event -> Html Msg
viewHour event =
    let
        toString =
            Date.format "H:mm"
    in
    toString event.start
        ++ " - "
        ++ toString event.end
        |> text
