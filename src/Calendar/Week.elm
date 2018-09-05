module Calendar.Week exposing (view, viewDate, viewDates, viewWeekContent, viewWeekDay, viewWeekHeader)

import Calendar.Day exposing (viewAllDayCell, viewDayEvents, viewDaySlotGroup, viewTimeGutter, viewTimeGutterHeader)
import Calendar.Event exposing (Event)
import Calendar.Helpers as Helpers
import Calendar.Msg exposing (Msg(..))
import Date exposing (Date)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)


viewWeekContent :
    List Event
    -> Maybe String
    -> Date
    -> List Date
    -> Dict String Date
    -> Html Msg
viewWeekContent events selectedId viewing days feries =
    let
        timeGutter =
            viewTimeGutter viewing

        weekDays =
            List.map (viewWeekDay events selectedId feries) days
    in
    div [ class "calendar--week-content" ]
        (timeGutter :: weekDays)


viewWeekDay : List Event -> Maybe String -> Dict String Date -> Date -> Html Msg
viewWeekDay events selectedId feries day =
    let
        viewDaySlots =
            Helpers.hours day
                |> List.map viewDaySlotGroup

        dayEvents =
            viewDayEvents events selectedId day feries
    in
    div [ class "calendar--day" ]
        [ div [ class "calendar--day-slot" ]
            (viewDaySlots ++ dayEvents)
        ]


view : List Event -> Maybe String -> Date -> Dict String Date -> Html Msg
view events selectedId viewing feries =
    let
        weekRange =
            Helpers.dayRangeOfWeek viewing
    in
    div [ class "calendar--week" ]
        [ viewWeekHeader weekRange
        , viewWeekContent events selectedId viewing weekRange feries
        ]


viewWeekHeader : List Date -> Html Msg
viewWeekHeader days =
    div [ class "calendar--week-header" ]
        [ viewDates days ]


viewDates : List Date -> Html Msg
viewDates days =
    div [ class "calendar--dates-header" ]
        [ viewTimeGutterHeader
        , div [ class "calendar--dates" ] <| List.map viewDate days
        ]


viewDate : Date -> Html Msg
viewDate day =
    div [ class "calendar--date-header" ]
        [ a [ class "calendar--date", href "#" ] [ text <| Helpers.dateString day ] ]
