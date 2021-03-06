module Main exposing (Model, Msg(..), main, model, myTask, update, view)

import Html as App exposing (..)
import Html.Events exposing (..)
import Process
import Task


type alias Model =
    String


model : Model
model =
    "not clicked"


myTask : Cmd Msg
myTask =
    Process.sleep (2 * 1000)
        |> Task.andThen (\_ -> Task.succeed (Debug.log "timeout" "not clicked"))
        |> Task.perform Foo


type Msg
    = Foo String
    | Bar
    | NoOp ()


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Foo str ->
            ( str, Cmd.none )

        Bar ->
            let
                txt =
                    if model == "not clicked" then
                        "clicked"

                    else
                        "not clickeed"

                cmd =
                    if model == "not clicked" then
                        myTask

                    else
                        Cmd.none
            in
            ( txt, cmd )

        NoOp _ ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Bar ] [ text "Click" ]
        , text model
        ]


main : Program Never Model Msg
main =
    App.program
        { init = ( model, myTask )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
