module View exposing (..)

import Date
import Date.Extra as Dateextra
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, targetValue, onClick)
import Json.Decode as Json

import Model exposing ( Model, Group, toDatetime )
import Msg exposing ( Msg(..) )
import Tooltip
import Config exposing (allGroups)

import Swipe exposing ( onSwipe )

import Calendar.Calendar as Calendar
import Calendar.Msg exposing (TimeSpan(..))

---- VIEW ----


view : Model -> Html Msg
view model =
    let
        events =
            model.data |> Maybe.withDefault []

        attrs = (Swipe.onSwipe SwipeEvent)
               ++
               [ class "main--container" ]

    in
        div attrs
            [ viewToolbar model.selectedGroup model.calendarState.viewing (model.calendarState.timeSpan == Week) model.loading
            , div [ class "main--calendar" ]
                [ Html.map SetCalendarState (Calendar.view events model.calendarState)
                ]
            , div [ (class ("main--message " ++ if model.loading then "" else "hidden")) ] ([] ++ if model.loading then [ text "Loading..." ] else [])
            , Tooltip.viewTooltip model.calendarState.hover events
            ]


viewToolbar : Group -> Date.Date -> Bool -> Bool -> Html Msg
viewToolbar selected viewing all loop =
    div [ class "main--toolbar" ]
        [ viewPagination all loop
        , viewTitle viewing
        , viewSelector selected
        -- , viewTimeSpanSelection timeSpan
        ]


viewTitle : Date.Date -> Html Msg
viewTitle viewing =
    div [ class "main--month-title", onClick ClickToday ]
        [ h2 [] [ text <| Dateextra.toFormattedString "MMMM yyyy" viewing ] ]


viewPagination : Bool -> Bool -> Html Msg
viewPagination all loop =
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
              [ button [ class "main--navigatiors-button", onClick ClickToday ] [ text "today" ]
              , reloadButton loop
              ]
            )


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


reloadButton: Bool -> Html Msg
reloadButton loop =
    button [ classList 
                [ ("main--navigatiors-button", True)
                , ("main--navigatiors-reload", True)
                , ("loop", loop)
                ]
           , style [ ("font-size", "1.2em") ]
           , onClick (SavedGroup "ok")
           ]
           [ span [] [ text "⟳" ]
           ]
