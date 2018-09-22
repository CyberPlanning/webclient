module Calendar.Day exposing (view, viewAllDayCell, viewDate, viewDayEvent, viewDayEvents, viewDayHeader, viewDaySlot, viewDaySlotGroup, viewHourSlot, viewTimeGutter, viewTimeGutterHeader, viewTimeSlot, viewTimeSlotGroup)

import Calendar.Event exposing (Event, maybeViewDayEvent, rangeDescription)
import Calendar.Helpers as Helpers
import Calendar.JourFerie exposing (jourFerie)
import Calendar.Msg exposing (Msg(..))
import Date exposing (Date)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


view : List Event -> Maybe String -> Date -> Dict String Date -> Html Msg
view events selectedId day feries =
    div [ class "calendar--day" ]
        [ viewDayHeader day
        , div [ class "calendar--day-content" ]
            [ viewTimeGutter day
            , div [ class "calendar--day" ]
                [ viewDaySlot events selectedId day feries ]
            ]
        ]


viewDate : Date -> Html Msg
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


viewDayHeader : Date -> Html Msg
viewDayHeader day =
    div [ class "calendar--day-header" ]
        [ viewTimeGutterHeader
        , viewDate day
        ]


viewTimeGutter : Date -> Html Msg
viewTimeGutter _ =
    Helpers.hours
        |> List.map viewTimeSlotGroup
        |> div [ class "calendar--time-gutter" ]


viewTimeGutterHeader : Html Msg
viewTimeGutterHeader =
    div [ class "calendar--time-gutter" ] []


viewTimeSlotGroup : String -> Html Msg
viewTimeSlotGroup date =
    div [ class "calendar--time-slot-group" ]
        [ viewHourSlot date
        , div [ class "calendar--time-slot" ] []
        ]


viewHourSlot : String -> Html Msg
viewHourSlot date =
    div [ class "calendar--hour-slot" ]
        [ span [ class "calendar--time-slot-text" ] [ text date ] ]


viewDaySlot : List Event -> Maybe String -> Date -> Dict String Date -> Html Msg
viewDaySlot events selectedId day feries =
    Helpers.hours
        |> List.map viewDaySlotGroup
        |> (\b a -> (++) a b) (viewDayEvents events selectedId day feries)
        |> div [ class "calendar--day-slot" ]


viewDaySlotGroup : String -> Html Msg
viewDaySlotGroup date =
    div [ class "calendar--time-slot-group" ]
        [ viewTimeSlot date
        , viewTimeSlot date
        ]


viewTimeSlot : String -> Html Msg
viewTimeSlot date =
    div
        [ class "calendar--time-slot" ]
        []


viewDayEvents : List Event -> Maybe String -> Date -> Dict String Date -> List (Html Msg)
viewDayEvents events selectedId day feries =
    let
        extra =
            case jourFerie feries day of
                Just name ->
                    text name
                        |> List.singleton
                        |> div [ class "calendar--jour-ferie" ]
                        |> List.singleton

                Nothing ->
                    []

        eventsHtml =
            List.filterMap (viewDayEvent day selectedId) events
    in
    extra ++ eventsHtml


viewDayEvent : Date -> Maybe String -> Event -> Maybe (Html Msg)
viewDayEvent day selectedId event =
    let
        eventRange =
            rangeDescription event.start event.end Date.Day day
    in
    maybeViewDayEvent event selectedId eventRange


viewAllDayCell : List Date -> Html Msg
viewAllDayCell days =
    let
        viewAllDayText =
            div [ class "calendar--all-day-text" ] [ text "All day" ]

        viewAllDay day =
            div [ class "calendar--all-day" ]
                []
    in
    div [ class "calendar--all-day-cell" ]
        (viewAllDayText :: List.map viewAllDay days)
