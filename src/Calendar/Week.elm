module Calendar.Week exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Date exposing (Date)
import Calendar.Day exposing (viewTimeGutter, viewTimeGutterHeader, viewDate, viewDaySlotGroup, viewAllDayCell, viewDayEvents)
import Calendar.Msg exposing (Msg)
import Calendar.Event exposing (Event)
import Calendar.Helpers as Helpers


viewWeekContent :
    List Event
    -> Maybe String
    -> Date
    -> List Date
    -> Html Msg
viewWeekContent events selectedId viewing days =
    let
        timeGutter =
            viewTimeGutter viewing

        weekDays =
            List.map (viewWeekDay events selectedId) days
    in
        div [ class "elm-calendar--week-content" ]
            (timeGutter :: weekDays)


viewWeekDay : List Event -> Maybe String -> Date -> Html Msg
viewWeekDay events selectedId day =
    let
        viewDaySlots =
            Helpers.hours day
                |> List.map viewDaySlotGroup

        dayEvents =
            viewDayEvents events selectedId day
    in
        div [ class "elm-calendar--day" ]
            (viewDaySlots ++ dayEvents)


view : List Event -> Maybe String -> Date -> Html Msg
view events selectedId viewing =
    let
        weekRange =
            Helpers.dayRangeOfWeek viewing
    in
        div [ class "elm-calendar--week" ]
            [ viewWeekHeader weekRange
            , viewWeekContent events selectedId viewing weekRange
            ]


viewWeekHeader : List Date -> Html Msg
viewWeekHeader days =
    div [ class "elm-calendar--week-header" ]
        [ viewDates days ]


viewDates : List Date -> Html Msg
viewDates days =
    div [ class "elm-calendar--dates-header" ]
        [ viewTimeGutterHeader
        , div [ class "elm-calendar--dates" ] <| List.map viewDate days
        ]
