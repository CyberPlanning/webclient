module View.Tooltip exposing (viewTooltip)

import Calendar.Event as CalEvent
import Calendar.Msg exposing (Position)
import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (WindowSize)
import Msg exposing (Msg(..))
import MyTime
import Time exposing (Posix)


viewTooltip : Maybe CalEvent.Event -> Maybe Position -> WindowSize -> Html Msg
viewTooltip maybeEvent maybePos screenSize =
    viewTooltipContent maybePos screenSize maybeEvent
        |> div [ class "tooltip" ]


viewTooltipContent : Maybe Position -> WindowSize -> Maybe CalEvent.Event -> List (Html Msg)
viewTooltipContent maybePos screenSize maybeEvent =
    case maybeEvent of
        Just event ->
            let
                badge =
                    if String.isEmpty event.source then
                        []

                    else
                        [ viewBadge event.source event.style ]

                title =
                    [ text event.title ] ++ badge
            in
            [ div ([ class "tooltip--event" ] ++ tooltipStylePos event.style maybePos screenSize)
                ([ div [ class "tooltip--event-title" ] title
                 , div [ class "tooltip--event-sub", class "tooltip--event-hours" ] [ viewHour event ]
                 ]
                    ++ showIfNotEmpty event.description
                )
            ]

        _ ->
            []


showIfNotEmpty : List String -> List (Html Msg)
showIfNotEmpty data =
    List.filter (\e -> String.isEmpty e == False) data
        |> List.map (\e -> div [ class "tooltip--event-sub" ] [ text e ])


tooltipStylePos : CalEvent.Style -> Maybe Position -> WindowSize -> List (Html.Attribute Msg)
tooltipStylePos { textColor, eventColor } maybePos { width, height } =
    let
        absoluteCoords =
            case maybePos of
                Just pos ->
                    let
                        posX =
                            pos.x
                                - 125
                                |> Basics.min (width - 252)
                                |> Basics.max 0
                                |> String.fromInt

                        posY =
                            pos.y
                                |> Basics.min (height - 152)
                                |> Basics.max 0
                                |> String.fromInt
                    in
                    [ style "left" (posX ++ "px"), style "top" (posY ++ "px") ]

                _ ->
                    [ style "bottom" "0" ]
    in
    [ style "background-color" eventColor, style "color" textColor ]
        ++ absoluteCoords


viewHour : CalEvent.Event -> Html Msg
viewHour event =
    toString event.startTime
        ++ " - "
        ++ toString event.endTime
        |> text


viewBadge : String -> CalEvent.Style -> Html Msg
viewBadge name { eventColor, textColor } =
    span [ class "tooltip--event-badge", style "background-color" textColor, style "color" eventColor ]
        [ text name ]


toString : Posix -> String
toString time =
    let
        minutes =
            MyTime.toMinute time
                |> String.fromInt
                |> String.padLeft 2 '0'

        hours =
            MyTime.toHour time
                |> String.fromInt
    in
    hours ++ ":" ++ minutes
