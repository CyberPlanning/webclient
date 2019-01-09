module Tooltip exposing (viewTooltip)

import Calendar.Event as CalEvent
import Calendar.Msg exposing (Position)
import Html exposing (..)
import Html.Attributes exposing (..)
import Msg exposing (Msg(..))
import Time exposing (Posix)
import TimeZone exposing (europe__paris)


viewTooltip : Maybe String -> Maybe Position -> List CalEvent.Event -> Html Msg
viewTooltip selectedId maybePos events =
    let
        content =
            case selectedId of
                Just id ->
                    List.filter (\e -> e.toId == id) events
                        |> List.head
                        |> viewTooltipContent maybePos

                _ ->
                    []
    in
    div [ class "tooltip" ] content


viewTooltipContent : Maybe Position -> Maybe CalEvent.Event -> List (Html Msg)
viewTooltipContent maybePos maybeEvent =
    case maybeEvent of
        Just event ->
            [ div ( [ class "tooltip--event" ] ++ tooltipStyle event.color maybePos)
                ([ div [ class "tooltip--event-title" ] [ text event.title ]
                 , div [ classList [ ( "tooltip--event-sub", True ), ( "tooltip--event-hours", True ) ] ] [ viewHour event ]
                 ]
                    ++ showIfNotEmpty [ String.join "," event.locations, String.join "," event.stakeholders, String.join "," event.groups ]
                )
            ]

        _ ->
            []


showIfNotEmpty : List String -> List (Html Msg)
showIfNotEmpty data =
    List.filter (\e -> String.isEmpty e == False) data
        |> List.map (\e -> div [ class "tooltip--event-sub" ] [ text e ])


tooltipStyle : String -> Maybe Position -> List (Html.Attribute Msg)
tooltipStyle color maybePos =
    let
        absoluteCoords =
            case maybePos of
                Just pos ->
                    let
                        posX =
                            pos.x + 5
                            |> String.fromInt
                        posY =
                            pos.y + 5
                            |> String.fromInt
                    in
                    [ style "left" (posX ++ "px"), style "top" ( posY ++ "px") ]

                _ ->
                    [ style "bottom" "0" ]
    in
    [ style "background-color" color ]
        ++ absoluteCoords


viewHour : CalEvent.Event -> Html Msg
viewHour event =
    toString event.startTime
        ++ " - "
        ++ toString event.endTime
        |> text


toString : Posix -> String
toString time =
    let
        minutes =
            Time.toMinute europe__paris time
                |> String.fromInt
                |> String.padLeft 2 '0'

        hours =
            Time.toHour europe__paris time
                |> String.fromInt
    in
    hours ++ ":" ++ minutes
