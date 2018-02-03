module View exposing (..)

import Date
import Date.Extra as Dateextra
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, targetValue, onClick)
import Json.Decode as Json

import Model exposing ( Model, Group, allGroups, toDatetime )
import Msg exposing ( Msg(..) )
import Tooltip

import Swipe exposing ( onSwipe )

import Calendar.Calendar as Calendar
import Calendar.Msg exposing (TimeSpan(..))

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

        events =
            model.data |> Maybe.withDefault []

        attrs = (Swipe.onSwipe SwipeEvent)
               ++
               [ class "main--container" ]

    in
        div attrs
            [ viewToolbar model.selectedGroup model.calendarState.viewing (model.calendarState.timeSpan == Week)
            , div [ class "main--calendar" ]
                [ Html.map SetCalendarState (Calendar.view events model.calendarState)
                ]
            , Tooltip.viewTooltip model.calendarState.hover events
            ]


viewToolbar : Group -> Date.Date -> Bool -> Html Msg
viewToolbar selected viewing all =
    div [ class "main--toolbar" ]
        [ viewPagination all
        , viewTitle viewing
        , viewSelector selected
        -- , viewTimeSpanSelection timeSpan
        ]


viewTitle : Date.Date -> Html Msg
viewTitle viewing =
    div [ class "main--month-title", onClick ClickToday ]
        [ h2 [] [ text <| Dateextra.toFormattedString "MMMM yyyy" viewing ] ]


viewPagination : Bool -> Html Msg
viewPagination all =
    let
        btns =
            if all then
                [ button [ class "main--navigatiors-button", onClick PageBack ] [ text "back" ]
                , button [ class "main--navigatiors-button", onClick PageForward ] [ text "next" ]
                ]
            else
                []

    in
        div [ class "main--paginators" ]
            ( btns 
              ++
              [ button [ class "main--navigatiors-button", onClick ClickToday ] [ text "today" ] ]
            )


-- viewTimeSpanSelection : TimeSpan -> Html Msg
-- viewTimeSpanSelection timeSpan =
--     div [ class "main--time-spans" ]
--         [ button [ class "main--button", onClick (ChangeTimeSpan Week) ] [ text "Week" ]
--         , button [ class "main--button", onClick (ChangeTimeSpan Day) ] [ text "Day" ]
--         ]


viewSelector : Group -> Html Msg
viewSelector selected =
    div [  class "main--selector" ]
        [ select [ class "main--selector-select" , id "groupSelect", on "change" <| Json.map SetGroup targetValue, value selected.slug ]
                 (List.map optionGroup allGroups)
        ]
    


optionGroup: Group -> Html Msg
optionGroup group =
    option [ value group.slug ]
           [ text group.name ]
