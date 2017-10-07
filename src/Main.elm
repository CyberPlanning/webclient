module Main exposing (..)

import Http exposing (Error)
import Html exposing (..)
import Html.Attributes exposing (value)
import Html.Events exposing (on, targetValue)
import Date
import Date.Extra as Dateextra
import Task
import Json.Decode as Json
import Types exposing (Query, Event, Planning, decodeQuery)
import Requests exposing (sendRequest, Msg(..), Group)


--import Json.Decode as Decode
---- MODEL ----


type alias PlanningResponse =
    Result Error Query


type alias Model =
    { data : Maybe PlanningResponse --Maybe (Result String Query)
    , date : Maybe Date.Date
    , selectedGroup : Group
    , loading : Bool
    }


allGroups: List Group
allGroups =
    [ { name = "Cyber1 TD1", slug = "11" }
    , { name = "Cyber1 TD2", slug = "12" }
    , { name = "Cyber2 TD1", slug = "21" }
    , { name = "Cyber2 TD2", slug = "22" }
    , { name = "Cyber3 TD1", slug = "31" }
    , { name = "Cyber3 TD2", slug = "32" }
    ]

toDatetime : Date.Date -> String
toDatetime =
    Dateextra.toFormattedString "y-MM-dd"


init : ( Model, Cmd Msg )
init =
    ( initialModel, Date.now |> Task.perform SetDate )


initialModel : Model
initialModel = 
    { data = Nothing
    , date = Nothing
    , selectedGroup = { name = "Cyber1 TD2", slug = "12" }
    , loading = False
    }


-- sendRequest "2017-09-29" ["12"]
---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetDate date ->
            --( { model | date = Just date, data = Just (Decode.decodeString decodeQuery """{"planning":{"events":[{"title":"Titre1","startDate":"2017-01-02T12:00:00Z","endDate":"2017-01-02T14:00:00Z","groups":["G1","G2"],"classrooms":["CR1","CR2"],"teachers":["M.Duhdeu","Mme.Feef"]}]}}""")}, Cmd.none )
            ( { model | date = Just date }, createPLanningRequest date model.selectedGroup.slug)

        GraphQlMsg response ->
            ( { model | data = Just response, loading = False }, Cmd.none )

        SetGroup slug ->
            let
                group =
                    Maybe.withDefault { slug = "12", name = "Cyber1 TD2" } <| find (\x -> x.slug == slug) allGroups

                cmd =
                    if model.loading then
                        Cmd.none
                    else
                        case model.date of
                            Just date ->
                                createPLanningRequest date slug

                            Nothing ->
                                Cmd.none
                
            in
                ( { model | selectedGroup = group, loading = True }, cmd )


createPLanningRequest: Date.Date -> String -> Cmd Msg
createPLanningRequest date slug =
    -- sendRequest (toDatetime (Dateextra.add Dateextra.Month -7 date)) (toDatetime (Dateextra.add Dateextra.Month 7 date)) [ slug ]
    sendRequest (toDatetime date) (toDatetime (Dateextra.add Dateextra.Week 1 date)) [ slug ]


find : (a -> Bool) -> List a -> Maybe a
find predicate list =
    case list of
        [] ->
            Nothing

        first::rest ->
            if predicate first then
                Just first
            else
                find predicate rest


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
        [ h2 [] [ text <| "Salut " ++ selected.name ++ " voila tes cours :" ]
        , select [ on "change" <| Json.map SetGroup targetValue ] 
                 (List.map optionGroup groups)
        ]


optionGroup: Group -> Html Msg
optionGroup group =
    option [ value group.slug ]
           [ text group.name ]

---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
