module Calendar.Event exposing (Event, EventRange(..), cellWidth, eventSegment, eventStyling, maybeViewDayEvent, offsetLength, offsetPercentage, percentDay, rangeDescription, rowSegment, styleDayEvent, styleRowSegment)

import Calendar.Helpers as Helpers
import Calendar.Msg exposing (Msg(..), TimeSpan(..))
import Date exposing (Date)
import Html exposing (..)
import Html.Attributes exposing (class, classList, style)
import Html.Events exposing (..)
import String


type alias Event =
    { toId : String
    , title : String
    , start : Date
    , end : Date
    , classrooms : List String
    , teachers : List String
    , groups : List String
    , color : String
    }


type EventRange
    = StartsAndEnds
    | ContinuesAfter
    | ContinuesPrior
    | ContinuesAfterAndPrior
    | ExistsOutside


rangeDescription : Date -> Date -> Date.Interval -> Date -> EventRange
rangeDescription start end interval date =
    let
        -- TODO
        -- Helpers.bumpMidnightBoundary date
        day =
            date

        begInterval =
            Date.floor interval day

        -- TODO
        -- |> Date.add Date.Millisecond -1
        endInterval =
            Date.ceiling interval day

        -- TODO
        startsThisInterval =
            isBetween begInterval endInterval start

        -- TODO
        endsThisInterval =
            isBetween begInterval endInterval end

        -- TODO
        -- Date.diff Date.Millisecond begInterval start
        --     |> (>) 0
        startsBeforeInterval =
            False

        -- TODO
        -- Date.diff Date.Millisecond end endInterval
        --     |> (>) 0
        endsAfterInterval =
            False
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

        eventColor =
            event.color

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
                    []

                Day ->
                    styleDayEvent eventStart eventEnd eventColor
    in
    [ classList (( classes, True ) :: customClasses) ] ++ styles


fractionalDay : Date -> Float
fractionalDay _ =
    0.5


percentDay : Date -> Float -> Float -> Float
percentDay date min max =
    (fractionalDay date - min) / (max - min)


styleDayEvent : Date -> Date -> String -> List (Html.Attribute msg)
styleDayEvent start end color =
    let
        startPercent =
            100 * percentDay start (7 / 24) (20 / 24)

        endPercent =
            -- TODO: remove + 0.2 tmp
            100 * (percentDay end (7 / 24) (20 / 24) + 0.2)

        height =
            (String.fromFloat <| endPercent - startPercent) ++ "%"

        startPercentage =
            String.fromFloat startPercent ++ "%"
    in
    [ style "top" startPercentage
    , style "height" height
    , style "left" "2%"
    , style "width" "96%"
    , style "position" "absolute"
    , style "background-color" color

    -- , ( "color" , if Helpers.isBright color then "black" else "white")
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
        ([ onMouseEnter <| EventMouseEnter eventId
         , onMouseLeave <| EventMouseLeave eventId
         , onClick <| EventMouseEnter eventId
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
    modBy 7 (Date.weekdayNumber date)
        |> toFloat
        |> (*) cellWidth


offsetPercentage : Date -> String
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


isBetween : Date -> Date -> Date -> Bool
isBetween start end current =
    let
        startInt =
            Date.toRataDie start

        endInt =
            Date.toRataDie end

        currentInt =
            Date.toRataDie current
    in
    startInt <= currentInt && endInt >= currentInt
