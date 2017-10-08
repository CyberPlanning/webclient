module Main exposing (..)

import Html
import Date
import Task

import View exposing (view)
import Model exposing (Model, initialModel)
import Update exposing ( update, Msg(..) )


---- PROGRAM ----


init : ( Model, Cmd Msg )
init =
    ( initialModel, Date.now |> Task.perform SetDate )


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
