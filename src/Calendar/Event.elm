module Calendar.Event exposing (..)

import Date exposing (Date)
import Date.Extra
import Html exposing (..)
import Html.Attributes exposing (class, classList, style)
import Html.Events exposing (..)
import Calendar.Msg exposing (Msg(..), TimeSpan(..))
import Calendar.Helpers as Helpers
import MD5

type alias Event =
    { toId: String
    , title: String
    , start: Date
    , end: Date
    , classrooms : (List String)
    , teachers : (List String)
    , groups : (List String)
    }

type EventRange
    = StartsAndEnds
    | ContinuesAfter
    | ContinuesPrior
    | ContinuesAfterAndPrior
    | ExistsOutside


rangeDescription : Date -> Date -> Date.Extra.Interval -> Date -> EventRange
rangeDescription start end interval date =
    let
        day =
            Helpers.bumpMidnightBoundary date

        begInterval =
            Date.Extra.floor interval day

        endInterval =
            Date.Extra.ceiling interval day
                |> Date.Extra.add Date.Extra.Millisecond -1

        startsThisInterval =
            Date.Extra.isBetween begInterval endInterval start

        endsThisInterval =
            Date.Extra.isBetween begInterval endInterval end

        startsBeforeInterval =
            Date.Extra.diff Date.Extra.Millisecond begInterval start
                |> (>) 0

        endsAfterInterval =
            Date.Extra.diff Date.Extra.Millisecond end endInterval
                |> (>) 0
    in
        if startsThisInterval && endsThisInterval then
            StartsAndEnds
        else if startsBeforeInterval && endsAfterInterval then
            ContinuesAfterAndPrior
        else if startsThisInterval && endsAfterInterval then
            ContinuesAfter
        else if endsThisInterval && startsBeforeInterval then
            ContinuesPrior
        else
            ExistsOutside


eventStyling :
    Event
    -> EventRange
    -> TimeSpan
    -> List ( String, Bool )
    -> List (Html.Attribute msg)
eventStyling event eventRange timeSpan customClasses =
    let
        eventStart =
            event.start

        eventEnd =
            event.end

        eventId =
            event.toId

        classes =
            case eventRange of
                StartsAndEnds ->
                    "calendar--event calendar--event-starts-and-ends"

                ContinuesAfter ->
                    "calendar--event calendar--event-continues-after"

                ContinuesPrior ->
                    "calendar--event calendar--event-continues-prior"

                ContinuesAfterAndPrior ->
                    "calendar--event"

                ExistsOutside ->
                    ""

        styles =
            case timeSpan of
                Week ->
                    style []

                Day ->
                    styleDayEvent eventStart eventEnd eventId
    in
        [ classList (( classes, True ) :: customClasses), styles ]


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


percentDay: Date -> Float -> Float -> Float
percentDay date min max = 
    ((Date.Extra.fractionalDay date) - min ) / (max-min)


styleDayEvent : Date -> Date -> String -> Html.Attribute msg
styleDayEvent start end id =
    let
        startPercent =
            100 * percentDay start (7/24) (20/24)

        endPercent =
            100 * percentDay end (7/24) (20/24)

        height =
            (toString <| endPercent - startPercent) ++ "%"

        startPercentage =
            (toString startPercent) ++ "%"

        bgColor =
            MD5.hex id
            |> String.right 6
            |> (++) "#"
    in
        style
            [ "top" => startPercentage
            , "height" => height
            , "left" => "2%"
            , "width" => "96%"
            , "position" => "absolute"
            , "background-color" => bgColor
            ]


maybeViewDayEvent : Event -> Maybe String -> EventRange -> Maybe (Html Msg)
maybeViewDayEvent event selectedId eventRange =
    case eventRange of
        ExistsOutside ->
            Nothing

        _ ->
            Just <| eventSegment event selectedId eventRange Day


eventSegment : Event -> Maybe String -> EventRange -> TimeSpan -> Html Msg
eventSegment event selectedId eventRange timeSpan =
    let
        eventId =
            event.toId

        isSelected =
            Maybe.map ((==) eventId) selectedId
                |> Maybe.withDefault False

        classes =
            [ ( "calendar--event-content", True )
            , ( "calendar--event-content--is-selected", isSelected )
            ]
    in
        div
            ([ onClick <| EventClick eventId
             , onMouseEnter <| EventMouseEnter eventId
             , onMouseLeave <| EventMouseLeave eventId
             ]
                ++ eventStyling event eventRange timeSpan classes
            )
            [ div [ class "calendar--event-title" ] [ text event.title ]
            , div [ class "calendar--event-sub" ] [ text <| String.join "," event.classrooms ]
            , div [ class "calendar--event-sub" ] [ text <| String.join "," event.teachers ]
            , div [ class "calendar--event-sub" ] [ text <| String.join "," event.groups ]
            ]


cellWidth : Float
cellWidth =
    100.0 / 7


offsetLength : Date -> Float
offsetLength date =
    (Date.Extra.weekdayNumber date)
        % 7
        |> toFloat
        |> (*) cellWidth


offsetPercentage : Date -> String
offsetPercentage date =
    (offsetLength date
        |> toString
    )
        ++ "%"


styleRowSegment : String -> Html.Attribute msg
styleRowSegment widthPercentage =
    style
        [ ( "flex-basis", widthPercentage )
        , ( "max-width", widthPercentage )
        ]


rowSegment : String -> List (Html Msg) -> Html Msg
rowSegment widthPercentage children =
    div [ styleRowSegment widthPercentage ] children
