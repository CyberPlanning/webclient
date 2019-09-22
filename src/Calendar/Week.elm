module Calendar.Week exposing (view, viewAll, viewWeekContent, viewWeekDay)

import Calendar.Day exposing (viewAllDayCell, viewDayEvents, viewDaySlotGroup, viewTimeGutter, viewTimeGutterHeader)
import Calendar.Event exposing (Event)
import Calendar.Helpers as Helpers
import Calendar.Msg exposing (InternalState, Msg(..))
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Time exposing (Posix)


view : InternalState -> List Event -> Html Msg
view state events =
    Helpers.dayRangeOfWeek state.viewing
        |> viewDays state events


viewAll : InternalState -> List Event -> Html Msg
viewAll state events =
    Helpers.dayRangeOfAllWeek state.viewing
        |> viewDays state events


viewDays : InternalState -> List Event -> List Posix -> Html Msg
viewDays state events weekRange =
    div [ class "calendar--week" ]
        [ viewWeekContent state events weekRange
        ]


viewWeekContent :
    InternalState
    -> List Event
    -> List Posix
    -> Html Msg
viewWeekContent state events days =
    let
        timeGutter =
            viewTimeGutter state.viewing

        weekDays =
            List.map (viewWeekDay state events) days
    in
    div [ class "calendar--week-content" ]
        (timeGutter :: weekDays)


viewWeekDay : InternalState -> List Event -> Posix -> Html Msg
viewWeekDay state events day =
    let
        viewDaySlots =
            Helpers.hours
                |> List.map viewDaySlotGroup

        dayEvents =
            viewDayEvents state events day
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
