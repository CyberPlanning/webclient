module Main exposing (main)

import Browser
import Browser.Dom
import Browser.Events
import Json.Decode as Decode
import Model exposing (Model)
import Msg exposing (Msg(..))
import Storage
import Task
import Update exposing (update)
import Utils exposing (initialModel)
import View exposing (view)



---- PROGRAM ----


init : Storage.Storage -> ( Model, Cmd Msg )
init storage =
    ( initialModel storage, Task.perform WindowSize Browser.Dom.getViewport )


main : Program Storage.Storage Model Msg
main =
    Browser.document
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Browser.Events.onKeyDown (Decode.map KeyDown keyDecoder)


keyDecoder : Decode.Decoder Int
keyDecoder =
    Decode.field "keyCode" Decode.int
