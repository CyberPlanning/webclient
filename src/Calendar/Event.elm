module Calendar.Event exposing (Event, PositionMode(..), Style, cellWidth, eventSegment, eventStyling, offsetLength, offsetPercentage, percentDay, rangeDescription, rowSegment, styleDayEvent, styleRowSegment)

-- import String.Extra

import Calendar.Helpers as Helpers
import Calendar.Msg exposing (InternalState, Msg(..), TimeSpan(..), onClick, onMouseEnter)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, style)
import Html.Events exposing (onMouseLeave)
import Iso8601
import MyTime
import String
import Time exposing (Posix, Weekday(..))
import Time.Extra as TimeExtra


type alias Style =
    { eventColor : String
    , textColor : String
    }


type alias Event =
    { toId : String
    , title : String
    , startTime : Posix
    , endTime : Posix
    , description : List String
    , source : String
    , style : Style
    , position : PositionMode
    }


type PositionMode
    = All
    | Column Int Int


rangeDescription : Posix -> Posix -> TimeExtra.Interval -> Posix -> Bool
rangeDescription start end interval date =
    let
        -- Fix : floor and ceiling return same Time if it is midnight
        day =
            MyTime.add TimeExtra.Millisecond 1 date

        begInterval =
            MyTime.floor interval day

        endInterval =
            MyTime.ceiling interval day

        startsThisInterval =
            isBetween begInterval endInterval start

        endsThisInterval =
            isBetween begInterval endInterval end
    in
    startsThisInterval && endsThisInterval


eventStyling :
    InternalState
    -> Event
    -> List ( String, Bool )
    -> List (Html.Attribute msg)
eventStyling state event customClasses =
    let
        eventStart =
            event.startTime

        eventEnd =
            event.endTime

        colorBg =
            event.style.eventColor

        colorFg =
            event.style.textColor

        eventTitle =
            escapeTitle event.title

        classes =
            "calendar--event calendar--event-starts-and-ends"

        extraStyle =
            if String.isEmpty event.source then
                []

            else
                [ style "border-color" colorFg ]

        styles =
            styleDayEvent state eventStart eventEnd event.position
                ++ styleColorDayEvent eventTitle colorFg colorBg
                ++ extraStyle
    in
    [ classList (( classes, True ) :: customClasses) ] ++ styles


fractionalDay : Posix -> Float
fractionalDay time =
    let
        hours =
            MyTime.toHour time

        minutes =
            MyTime.toMinute time

        seconds =
            MyTime.toSecond time
    in
    toFloat ((hours * 3600) + (minutes * 60) + seconds) / (24 * 3600)


percentDay : Posix -> Float -> Float -> Float
percentDay date min max =
    (fractionalDay date - min) / (max - min)


styleDayEvent : InternalState -> Posix -> Posix -> PositionMode -> List (Html.Attribute msg)
styleDayEvent state start end position =
    let
        ( left, width ) =
            case position of
                All ->
                    ( "0", "96%" )

                Column idx size ->
                    let
                        fractionUnit =
                            96 / toFloat state.columns

                        fractionSize =
                            fractionUnit * toFloat size

                        l =
                            idx
                                |> toFloat
                                |> (*) fractionUnit
                                |> String.fromFloat
                                |> (\x -> x ++ "%")

                        w =
                            fractionSize
                                |> String.fromFloat
                                |> (\x -> x ++ "%")
                    in
                    ( l, w )

        startPercent =
            100 * percentDay start (7 / 24) (21 / 24)

        endPercent =
            100 * percentDay end (7 / 24) (21 / 24)

        height =
            (String.fromFloat <| endPercent - startPercent) ++ "%"

        startPercentage =
            String.fromFloat startPercent ++ "%"
    in
    [ style "top" startPercentage
    , style "height" height
    , style "left" left
    , style "margin" "0 6px"
    , style "width" width
    , style "position" "absolute"
    ]


styleColorDayEvent : String -> String -> String -> List (Html.Attribute msg)
styleColorDayEvent title fg bg =
    [ style "background-color" bg
    , style "color" fg
    , attribute "data-title" title
    , attribute "data-color" fg
    ]


eventSegment : InternalState -> Event -> Html Msg
eventSegment state event =
    let
        eventId =
            event.toId

        classes =
            [ ( "calendar--event-content", True )
            ]

        title =
            [ text event.title ]

        childs =
            List.map viewSub event.description
    in
    div []
        [ div
            ([ onMouseEnter <| EventMouseEnter eventId
             , onMouseLeave <| EventMouseLeave eventId
             , onClick <| EventClick eventId
             ]
                ++ eventStyling state event classes
            )
            (div [ class "calendar--event-title" ] title :: childs)
        ]


makeTitle : String -> Html Msg
makeTitle title =
    text title


viewSub : String -> Html Msg
viewSub val =
    div [ class "calendar--event-sub" ] [ text val ]


cellWidth : Float
cellWidth =
    100.0 / 7


offsetLength : Posix -> Float
offsetLength date =
    MyTime.toWeekday date
        |> MyTime.weekdayToNumber
        |> modBy 7
        |> toFloat
        |> (*) cellWidth


offsetPercentage : Posix -> String
offsetPercentage date =
    (offsetLength date
        |> String.fromFloat
    )
        ++ "%"


styleRowSegment : String -> List (Html.Attribute msg)
styleRowSegment widthPercentage =
    [ style "flex-basis" widthPercentage
    , style "max-width" widthPercentage
    ]


rowSegment : String -> List (Html Msg) -> Html Msg
rowSegment widthPercentage children =
    div (styleRowSegment widthPercentage) children


isBetween : Posix -> Posix -> Posix -> Bool
isBetween start end current =
    let
        startInt =
            Time.posixToMillis start

        endInt =
            Time.posixToMillis end

        currentInt =
            Time.posixToMillis current
    in
    startInt <= currentInt && endInt >= currentInt


escapeTitle : String -> String
escapeTitle =
    always ""
