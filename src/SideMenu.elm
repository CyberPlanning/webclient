module SideMenu exposing (view)

import Calendar.Msg exposing (TimeSpan(..))
import Config exposing (allGroups)
import Html exposing (Html, a, button, div, i, input, label, option, select, span, text)
import Html.Attributes exposing (attribute, checked, class, for, href, id, multiple, style, target, title, type_, value)
import Html.Events exposing (on, onCheck, onClick, targetValue)
import Json.Decode as Json
import Model exposing (Group, Settings)
import Msg exposing (Msg(..))
import Svg exposing (path, svg)
import Svg.Attributes exposing (d, fillRule, height, version, viewBox, width)
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


githubButton : Html msg
githubButton =
    a
        [ class "sidemenu--github-btn", href "https://github.com/cyberplanning/webclient", target "_blank" ]
        [ svg
            [ version "1.1", width "16", height "16", viewBox "0 0 16 16" ]
            [ path
                [ fillRule "evenodd", d "M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z" ]
                []
            ]
        , span [] [ text "Star" ]
        ]
