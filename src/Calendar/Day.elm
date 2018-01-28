module Calendar.Day exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Date exposing (Date)
import Date.Extra
import Calendar.Helpers as Helpers
import Calendar.Msg exposing (Msg(..))
import Calendar.Event exposing (rangeDescription, maybeViewDayEvent, Event)


view : List Event -> Maybe String -> Date -> Html Msg
view events selectedId day =
    div [ class "elm-calendar--day" ]
        [ viewDayHeader day
        , div [ class "elm-calendar--day-content" ]
            [ viewTimeGutter day
            , viewDaySlot events selectedId day
            ]
        ]


viewDate : Date -> Html Msg
viewDate day =
    let
        title day =
            Date.Extra.toFormattedString "EEEE dd MMM" day
    in
        div [ class "elm-calendar--date-header" ]
            [ a [ class "elm-calendar--date", href "#" ] [ text <| title day ] ]


viewDayHeader : Date -> Html Msg
viewDayHeader day =
    div [ class "elm-calendar--day-header" ]
        [ viewTimeGutterHeader
        , viewDate day
        ]


viewTimeGutter : Date -> Html Msg
viewTimeGutter date =
    Helpers.hours date
        |> List.map viewTimeSlotGroup
        |> div [ class "elm-calendar--time-gutter" ]


viewTimeGutterHeader : Html Msg
viewTimeGutterHeader =
    div [ class "elm-calendar--time-gutter-header" ] []


viewTimeSlotGroup : Date -> Html Msg
viewTimeSlotGroup date =
    div [ class "elm-calendar--time-slot-group" ]
        [ viewHourSlot date
        , div [ class "elm-calendar--time-slot" ] []
        ]


viewHourSlot : Date -> Html Msg
viewHourSlot date =
    div [ class "elm-calendar--hour-slot" ]
        [ span [ class "elm-calendar--time-slot-text" ] [ text <| Helpers.hourString date ] ]


viewDaySlot : List Event -> Maybe String -> Date -> Html Msg
viewDaySlot events selectedId day =
    Helpers.hours day
        |> List.map viewDaySlotGroup
        |> (flip (++)) (viewDayEvents events selectedId day)
        |> div [ class "elm-calendar--day-slot" ]


viewDaySlotGroup : Date -> Html Msg
viewDaySlotGroup date =
    div [ class "elm-calendar--time-slot-group" ]
        [ viewTimeSlot date
        , viewTimeSlot date
        ]


viewTimeSlot : Date -> Html Msg
viewTimeSlot date =
    div
        [ class "elm-calendar--time-slot" ]
        []


viewDayEvents : List Event -> Maybe String -> Date -> List (Html Msg)
viewDayEvents events selectedId day =
    List.filterMap (viewDayEvent day selectedId) events


viewDayEvent : Date -> Maybe String -> Event -> Maybe (Html Msg)
viewDayEvent day selectedId event =
    let
        eventRange =
            rangeDescription event.start event.end Date.Extra.Day day
    in
        maybeViewDayEvent event selectedId eventRange


viewAllDayCell : List Date -> Html Msg
viewAllDayCell days =
    let
        viewAllDayText =
            div [ class "elm-calendar--all-day-text" ] [ text "All day" ]

        viewAllDay day =
            div [ class "elm-calendar--all-day" ]
                []
    in
        div [ class "elm-calendar--all-day-cell" ]
            (viewAllDayText :: List.map viewAllDay days)
