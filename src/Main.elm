module Main exposing (..)

import Html
import Window
import Task

import View exposing (view)
import Model exposing (Model, initialModel)
import Update exposing ( update )
import Msg exposing ( Msg(..) )


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
        , subscriptions = always Sub.none
        }
