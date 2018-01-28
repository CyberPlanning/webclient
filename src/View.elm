module View exposing (..)

import Date
import Date.Extra as Dateextra
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, targetValue, onClick)
import Json.Decode as Json

import Model exposing ( Model, Group, allGroups, toDatetime )
import Msg exposing ( Msg(..) )
import Types exposing (..)

import Calendar.Calendar as Calendar
import Calendar.Event as CalEvent

---- VIEW ----


view : Model -> Html Msg
view model =
    let
        datetime =
            case model.date of
                Just date ->
                    toDatetime date

                Nothing ->
                    "Nothing"

        events = case model.data of
                Just (Ok query) ->
                    if List.isEmpty query.planning.events then
                        []
                    else
                        toCalEvents query.planning.events

                _ ->
                    []

    in
        div [ class "main--container"]
            [ viewToolbar model.selectedGroup (Maybe.withDefault (Date.fromTime 0 )model.date)
            , div [ class "main--calendar" ]
                [ Html.map SetCalendarState (Calendar.view events model.calendarState) ]
            ]


toCalEvents : List Event -> List CalEvent.Event
toCalEvents events =
    List.map toCalEvent events


toCalEvent : Event -> CalEvent.Event
toCalEvent event =
        { toId = event.title
        , title = event.title
        , start = parseDateEvent event.startDate
        , end = parseDateEvent event.endDate
        , classrooms = event.classrooms
        , teachers = event.teachers
        , groups = event.groups
        }


viewToolbar : Group -> Date.Date -> Html Msg
viewToolbar selected viewing =
    div [ class "elm-calendar--toolbar" ]
        [ viewPagination
        , viewTitle viewing
        , select [ on "change" <| Json.map SetGroup targetValue, value selected.slug ] (List.map optionGroup allGroups)
        -- , viewTimeSpanSelection timeSpan
        ]


viewTitle : Date.Date -> Html Msg
viewTitle viewing =
    div [ class "elm-calendar--month-title" ]
        [ h2 [] [ text <| Dateextra.toFormattedString "MMMM yyyy" viewing ] ]


viewPagination : Html Msg
viewPagination =
    div [ class "elm-calendar--paginators" ]
        [ button [ class "elm-calendar--button", onClick PageBack ] [ text "back" ]
        , button [ class "elm-calendar--button", onClick PageForward ] [ text "next" ]
        ]


-- viewTimeSpanSelection : TimeSpan -> Html Msg
-- viewTimeSpanSelection timeSpan =
--     div [ class "elm-calendar--time-spans" ]
--         [ button [ class "elm-calendar--button", onClick (ChangeTimeSpan Week) ] [ text "Week" ]
--         , button [ class "elm-calendar--button", onClick (ChangeTimeSpan Day) ] [ text "Day" ]
--         ]


optionGroup: Group -> Html Msg
optionGroup group =
    option [ value group.slug ]
           [ text group.name ]


parseDateEvent: String -> Date.Date
parseDateEvent date =
    date ++ "Z"
    |> Dateextra.fromIsoString
    |> Maybe.withDefault (Date.fromTime 0)
