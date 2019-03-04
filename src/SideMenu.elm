module SideMenu exposing (view)

import Calendar.Msg exposing (TimeSpan(..))
import Config exposing (allGroups)
import Html exposing (Html, a, button, div, i, input, label, option, select, span, text)
import Html.Attributes exposing (attribute, checked, class, for, id, multiple, style, title, type_, value)
import Html.Events exposing (on, onCheck, onClick, targetValue)
import Json.Decode as Json
import Model exposing (Group, Settings)
import Msg exposing (Msg(..))
import Utils exposing (groupId)


view : Group -> TimeSpan -> Settings -> Html Msg
view group timespan { menuOpened, showCustom, showHack2g2 } =
    div
        [ class "sidemenu--container"
        , style "display"
            (if menuOpened then
                "flex"

             else
                "none"
            )
        ]
        [ div
            [ class "sidemenu--main" ]
            [ viewSelector group
            , hack2g2Checkbox showHack2g2
            , customCheckbox showCustom
            , modeButton Week "Week"
            , modeButton AllWeek "All Week"
            , modeButton Day "Day"
            ]
        , div
            [ class "sidemenu--footer" ]
            [ div
                [ class "sidemenu--footer-content" ]
                [ a [] [ i [ class "icon-secure" ] [] ]
                , span [] [ text "Secured by CP" ]
                ]
            ]
        ]


viewSelector : Group -> Html Msg
viewSelector selected =
    div [ class "sidemenu--selector" ]
        [ label [ for "select-group" ] [ text "Groupes" ]
        , select
            [ class "sidemenu--selector"
            , style "color" "white"
            , id "select-group"
            , on "change" <| Json.map SetGroup targetValue
            , value (String.fromInt (groupId selected))
            , multiple False
            ]
            (List.map optionGroup allGroups)
        ]


optionGroup : Group -> Html Msg
optionGroup group =
    option [ value (String.fromInt (groupId group)) ]
        [ text group.name ]


hack2g2Checkbox : Bool -> Html Msg
hack2g2Checkbox isChecked =
    div [ class "md-checkbox" ]
        [ input [ id "check-hack2g2", type_ "checkbox", checked isChecked, onCheck (CheckEvents Model.Hack2g2) ] []
        , label [ for "check-hack2g2" ] [ text "Hack2g2" ]
        ]


customCheckbox : Bool -> Html Msg
customCheckbox isChecked =
    div [ class "md-checkbox" ]
        [ input [ id "check-custom", type_ "checkbox", checked isChecked, onCheck (CheckEvents Model.Custom) ] []
        , label [ for "check-custom" ] [ text "Custom" ]
        ]


modeButton : TimeSpan -> String -> Html Msg
modeButton mode name =
    div []
        [ button [ onClick (ChangeMode mode), attribute "aria-label" ("Toggle Mode " ++ name) ] [ text name ]
        ]
