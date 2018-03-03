module Main exposing (..)

import Html
import Window
import Task
import Keyboard

import View exposing (view)
import Model exposing (Model, initialModel)
import Update exposing ( update )
import Msg exposing ( Msg(..) )
import Storage


---- PROGRAM ----


init : ( Model, Cmd Msg )
init =
    ( initialModel, Task.perform WindowSize Window.size )


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model = 
    Sub.batch
        [ Storage.load LoadGroup
        , Storage.saved SavedGroup
        , Keyboard.downs KeyDown
        ]
