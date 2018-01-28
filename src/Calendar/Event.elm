module Calendar.Event exposing (..)

import Date exposing (Date)
import Date.Extra
import Html exposing (..)
import Html.Attributes exposing (class, classList, style)
import Html.Events exposing (..)
import Calendar.Msg exposing (Msg(..), TimeSpan(..))
import Calendar.Config exposing (ViewConfig)
import Calendar.Helpers as Helpers
import MD5


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
    ViewConfig event
    -> event
    -> EventRange
    -> TimeSpan
    -> List ( String, Bool )
    -> List (Html.Attribute msg)
eventStyling config event eventRange timeSpan customClasses =
    let
        eventStart =
            config.start event

        eventEnd =
            config.end event

        eventId =
            config.toId event

        classes =
            case eventRange of
                StartsAndEnds ->
                    "elm-calendar--event elm-calendar--event-starts-and-ends"

                ContinuesAfter ->
                    "elm-calendar--event elm-calendar--event-continues-after"

                ContinuesPrior ->
                    "elm-calendar--event elm-calendar--event-continues-prior"

                ContinuesAfterAndPrior ->
                    "elm-calendar--event"

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


maybeViewDayEvent : ViewConfig event -> event -> Maybe String -> EventRange -> Maybe (Html Msg)
maybeViewDayEvent config event selectedId eventRange =
    case eventRange of
        ExistsOutside ->
            Nothing

        _ ->
            Just <| eventSegment config event selectedId eventRange Day


eventSegment : ViewConfig event -> event -> Maybe String -> EventRange -> TimeSpan -> Html Msg
eventSegment config event selectedId eventRange timeSpan =
    let
        eventId =
            config.toId event

        isSelected =
            Maybe.map ((==) eventId) selectedId
                |> Maybe.withDefault False

        { nodeName, classes, children } =
            config.event event isSelected
    in
        node nodeName
            ([ onClick <| EventClick eventId
             , onMouseEnter <| EventMouseEnter eventId
             , onMouseLeave <| EventMouseLeave eventId
             ]
                ++ eventStyling config event eventRange timeSpan classes
            )
            children


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
