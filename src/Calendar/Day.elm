module Calendar.Day exposing (view, viewAllDayCell, viewDate, viewDayEvent, viewDayEvents, viewDayHeader, viewDaySlot, viewDaySlotGroup, viewHourSlot, viewTimeGutter, viewTimeGutterHeader, viewTimeSlot, viewTimeSlotGroup)

import Calendar.Event exposing (Event, eventSegment, rangeDescription)
import Calendar.Helpers as Helpers
import Calendar.JourFerie exposing (jourFerie)
import Calendar.Msg exposing (InternalState, Msg(..))
import Html exposing (Html, div, button, text, span)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import MyTime
import Time exposing (Posix)
import Time.Extra as TimeExtra


view : InternalState -> Int -> List Event -> Html Msg
view state columns events =
    div [ class "calendar--day" ]
        [ div [ class "calendar--day-content" ]
            [ viewTimeGutter state.viewing
            , div [ class "calendar--day" ]
                [ viewDayHeader state.viewing
                , viewDaySlot state columns events
                ]
            ]
        ]


viewDate : Posix -> Html Msg
viewDate day =
    div [ class "calendar--date-header" ]
        [ button [ class "calendar--navigations-week", onClick WeekBack ] [ text "<<" ]
        , div [ class "calendar--date-header-content" ]
            [ button [ class "calendar--navigations-day", onClick PageBack ] [ text "<" ]
            , span [ class "calendar--date" ] [ text <| Helpers.dateString day ]
            , button [ class "calendar--navigations-day", onClick PageForward ] [ text ">" ]
            ]
        , button [ class "calendar--navigations-week", onClick WeekForward ] [ text ">>" ]
        ]


viewDayHeader : Posix -> Html Msg
viewDayHeader day =
    div [ class "calendar--day-header" ]
        [ viewDate day
        ]


viewTimeGutter : Posix -> Html Msg
viewTimeGutter viewing =
    Helpers.hours
        |> List.indexedMap (viewTimeSlotGroup viewing)
        |> (::) (viewTimeGutterHeader viewing)
        |> div [ class "calendar--time-gutter" ]


viewTimeGutterHeader : Posix -> Html Msg
viewTimeGutterHeader viewing =
    let
        date =
            viewing
                |> MyTime.ceiling TimeExtra.Sunday

        weekNum =
            MyTime.diff TimeExtra.Week
                (MyTime.floor TimeExtra.Year date)
                date
                |> (+) 1
                |> String.fromInt
    in
    div [ class "calendar--date-header", class "calendar--date-header-weeknum" ]
        [ span [ class "calendar--date" ] [ text weekNum ]
        ]


viewTimeGutterZone : Posix -> Html Msg
viewTimeGutterZone viewing =
    let
        offset =
            viewing
                |> MyTime.toOffset

        zone =
            offset
                / 60
                |> floor
                |> String.fromInt
                |> (++) "GMT+"
    in
    div [ class "calendar--date-header-zone" ]
        [ span [] [ text zone ]
        ]


viewTimeSlotGroup : Posix -> Int -> String -> Html Msg
viewTimeSlotGroup viewing idx date =
    div [ class "calendar--time-slot-group" ]
        [ if idx == 0 then
            viewTimeGutterZone viewing

          else
            text ""
        , viewHourSlot date
        , div [ class "calendar--time-slot" ] []
        ]


viewHourSlot : String -> Html Msg
viewHourSlot date =
    div [ class "calendar--hour-slot" ]
        [ span [ class "calendar--time-slot-text" ] [ text date ] ]


viewDaySlot : InternalState -> Int -> List Event -> Html Msg
viewDaySlot state columns events =
    Helpers.hours
        |> List.map viewDaySlotGroup
        |> (\b a -> a ++ b) (viewDayEvents state columns events state.viewing)
        |> div [ class "calendar--day-slot" ]


viewDaySlotGroup : String -> Html Msg
viewDaySlotGroup date =
    div [ class "calendar--time-slot-group" ]
        [ viewTimeSlot date
        , viewTimeSlot date
        ]


viewTimeSlot : String -> Html Msg
viewTimeSlot _ =
    div
        [ class "calendar--time-slot" ]
        []


viewDayEvents : InternalState -> Int -> List Event -> Posix -> List (Html Msg)
viewDayEvents state columns events day =
    let
        extra =
            case jourFerie state.joursFeries day of
                Just name ->
                    text name
                        |> List.singleton
                        |> div [ class "calendar--jour-ferie" ]
                        |> List.singleton

                Nothing ->
                    []

        eventsHtml =
            List.filterMap (viewDayEvent columns day) events
    in
    extra ++ eventsHtml


viewDayEvent : Int -> Posix -> Event -> Maybe (Html Msg)
viewDayEvent columns day event =
    if rangeDescription event.startTime event.endTime TimeExtra.Day day then
        Just <| eventSegment columns event

    else
        Nothing


viewAllDayCell : List Posix -> Html Msg
viewAllDayCell days =
    let
        viewAllDayText =
            div [ class "calendar--all-day-text" ] [ text "All day" ]

        viewAllDay _ =
            div [ class "calendar--all-day" ]
                []
    in
    div [ class "calendar--all-day-cell" ]
        (viewAllDayText :: List.map viewAllDay days)
