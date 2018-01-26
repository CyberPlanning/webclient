module View exposing (..)

import Date
import Date.Extra as Dateextra
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, targetValue)
import Json.Decode as Json

import Model exposing ( Model, Group, allGroups, toDatetime )
import Requests exposing ( Msg(..) )
import Types exposing (..)

import Calendar.Calendar as Calendar

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
                        query.planning.events

                _ ->
                    []

        planning =
            case model.data of
                Just (Ok query) ->
                    if List.isEmpty query.planning.events then
                        text "Vide :("
                    else
                        viewPlanning query.planning.events

                Just (Err error) ->
                    text <| toString error

                Nothing ->
                    text "Loading"
    in
        div [ class "main--container"]
            [ viewHeader model.selectedGroup allGroups
            , div [ class "main--calendar" ]
                [ Html.map SetCalendarState (Calendar.view viewConfig events model.calendarState) ]
            ]


viewPlanning : List Event -> Html Msg
viewPlanning events =
    div [] <| List.map (Debug.log "" >> viewEvent) events


viewEvent: Event -> Html Msg
viewEvent event =
    div []
        [ h2 [] [ text event.title ]
        , p [] [ text ( "De " ++ ( viewDateFormat event.startDate firstDateParser ) ++ " à " ++ ( viewDateFormat event.endDate secondDateParser ) ) ]
        , p [] [ text <| String.join ", " event.classrooms ]
        , p [] [ text <| String.join ", " event.groups ]
        , p [] [ text <| String.join ", " event.teachers ]
        ]


viewDateFormat: String -> ( Date.Date -> String ) -> String
viewDateFormat dateString parser =
    let
        parsedDate = Dateextra.fromIsoString (dateString ++ "Z")
    in
        case parsedDate of
            Just date ->
                parser date

            Nothing ->
                "Invalid : " ++ dateString


firstDateParser : Date.Date -> String
firstDateParser =
    Dateextra.toFormattedString "eeee dd/MM HH:mm"


secondDateParser : Date.Date -> String
secondDateParser =
    Dateextra.toFormattedString "HH:mm"


viewHeader: Group -> List Group -> Html Msg
viewHeader selected groups=
    div []
        [ select [ on "change" <| Json.map SetGroup targetValue, value selected.slug ] (List.map optionGroup groups) ]


optionGroup: Group -> Html Msg
optionGroup group =
    option [ value group.slug ]
           [ text group.name ]


parseDateEvent: (Event -> String) -> Event -> Date.Date
parseDateEvent date ev =
    (date ev) ++ "Z"
    |> Dateextra.fromIsoString
    |> Maybe.withDefault (Date.fromTime 0)


viewConfig : Calendar.ViewConfig Event
viewConfig =
    Calendar.viewConfig
        { toId = .title
        , title = .title
        , start = parseDateEvent .startDate
        , end = parseDateEvent .endDate
        , event =
            \event isSelected ->
                Calendar.eventView
                    { nodeName = "div"
                    , classes =
                        [ ( "elm-calendar--event-content", True )
                        , ( "elm-calendar--event-content--is-selected", isSelected )
                        ]
                    , children =
                        [ div []
                            [ text <| event.title ]
                        ]
                    }
        }