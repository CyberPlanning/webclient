module View exposing (..)

import Date
import Date.Extra as Dateextra
import Html exposing (..)
import Html.Attributes exposing (value)
import Html.Events exposing (on, targetValue)
import Json.Decode as Json

import Model exposing ( Model, Group, allGroups, toDatetime )
import Requests exposing ( Msg(..) )
import Types exposing (..)

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

        planning =
            case model.data of
                Just (Ok query) ->
                    if List.isEmpty query.planning.events then
                        text "Vide :("
                    else
                        viewPlanning query

                Just (Err error) ->
                    text <| toString error

                Nothing ->
                    text "Loading"
    in
        div []
            [ viewHeader model.selectedGroup allGroups
            , div []
                [ datetime |> toString |> text ]
            , div []
                [ model.loading |> toString |> text ]
            , div []
                [ planning ]
            ]


viewPlanning : Query -> Html Msg
viewPlanning query =
    div [] <| List.map viewEvent query.planning.events


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
        [ h2 [] [ text <| "Salut " ++ selected.name ++ " voila tes cours connard:" ]
        , select [ on "change" <| Json.map SetGroup targetValue ] 
                 (List.map optionGroup groups)
        ]


optionGroup: Group -> Html Msg
optionGroup group =
    option [ value group.slug ]
           [ text group.name ]
