module View.SideMenu exposing (view)

import Calendar.Msg exposing (TimeSpan(..))
import Config exposing (allGroups)
import Html exposing (Html, a, button, div, i, input, label, option, select, span, text)
import Html.Attributes exposing (attribute, checked, class, for, href, id, multiple, style, target, title, type_, value)
import Html.Events exposing (on, onCheck, onClick, targetValue)
import Json.Decode as Json
import Model exposing (Group, Settings)
import Msg exposing (Msg(..))
import MultiSelect exposing (..)
import Svg exposing (path, svg)
import Svg.Attributes exposing (d, fillRule, height, version, viewBox, width)
import Utils exposing (getGroupId)


view : List Group -> TimeSpan -> Settings -> Html Msg
view groups timespan { menuOpened, showCustom, showHack2g2 } =
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
            [ viewMultiSelector groups
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
                [ div [ class "sidemenu--row" ] [ githubButton ]
                , div
                    [ class "sidemenu--row" ]
                    [ a [] [ i [ class "icon-secure" ] [] ]
                    , span [] [ text "Secured by" ]
                    , span [ title "CyberPlanning", style "margin-left" "3px" ] [ text "CP" ]
                    ]
                ]
            ]
        ]


myOption : Options Msg
myOption =
    { items = List.map (\x -> { value = String.fromInt x.id, text = x.name, enabled = True }) allGroups
    , onChange = SetGroups
    }


viewMultiSelector : List Group -> Html Msg
viewMultiSelector selectedGroups =
    div [ class "sidemenu--selector" ]
        [ label [ for "select-group" ] [ text "Groupes" ]
        , multiSelect
            myOption
            [ class "sidemenu--selector"
            , style "color" "white"
            , id "select-group"
            ]
            (List.map (.id >> String.fromInt) selectedGroups)
        ]


optionGroup : Group -> Html Msg
optionGroup group =
    option [ value (String.fromInt (getGroupId group)) ]
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


githubButton : Html msg
githubButton =
    a
        [ class "sidemenu--github-btn", href "https://github.com/cyberplanning/webclient", target "_blank" ]
        [ i [ class "icon-github" ] []
        , span [] [ text "Star" ]
        ]
