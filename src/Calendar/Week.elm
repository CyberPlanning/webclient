module Calendar.Week exposing (view, viewAll, viewWeekContent, viewWeekDay)

import Calendar.Day exposing (viewAllDayCell, viewDayEvents, viewDaySlotGroup, viewTimeGutter, viewTimeGutterHeader)
import Calendar.Event exposing (Event)
import Calendar.Helpers as Helpers
import Calendar.Msg exposing (InternalState, Msg(..))
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Time exposing (Posix)


view : InternalState -> Int -> List Event -> Html Msg
view state columns events =
    Helpers.dayRangeOfWeek state.viewing
        |> viewDays state columns events


viewAll : InternalState -> Int -> List Event -> Html Msg
viewAll state columns events =
    Helpers.dayRangeOfAllWeek state.viewing
        |> viewDays state columns events


viewDays : InternalState -> Int -> List Event -> List Posix -> Html Msg
viewDays state columns events weekRange =
    div [ class "calendar--week" ]
        [ viewWeekContent state columns events weekRange
        ]


viewWeekContent :
    InternalState
    -> Int
    -> List Event
    -> List Posix
    -> Html Msg
viewWeekContent state columns events days =
    let
        timeGutter =
            viewTimeGutter state.viewing

        weekDays =
            List.map (viewWeekDay state columns events) days
    in
    div [ class "calendar--week-content" ]
        (timeGutter :: weekDays)


viewWeekDay : InternalState -> Int -> List Event -> Posix -> Html Msg
viewWeekDay state columns events day =
    let
        viewDaySlots =
            Helpers.hours
                |> List.map viewDaySlotGroup

        dayEvents =
            viewDayEvents state columns events day
    in
    div [ class "calendar--dates" ]
        [ div [ class "calendar--date-header" ]
            [ span [ class "calendar--date" ] [ text <| Helpers.dateString day ] ]
        , div [ class "calendar--day-slot" ]
            (viewDaySlots ++ dayEvents)
        ]



-- viewWeekHeader : List Posix -> Html Msg
-- viewWeekHeader days =
--     div [ class "calendar--week-header" ]
--         [ viewDates days ]
-- viewDates : List Posix -> Html Msg
-- viewDates days =
--     div [ class "calendar--dates-header" ]
--         [ viewTimeGutterHeader
--         , div [ class "calendar--dates" ] <| List.map viewDate days
--         ]
-- viewDate : Posix -> Html Msg
-- viewDate day =
--     div [ class "calendar--date-header" ]
--         [ span [ class "calendar--date" ] [ text <| Helpers.dateString day ] ]
