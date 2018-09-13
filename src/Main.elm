module Main exposing (init, main, subscriptions)

import Browser
import Browser.Dom
import Browser.Events
import Json.Decode as Decode
import Model exposing (Model, initialModel)
import Msg exposing (Msg(..))
import Storage
import Task
import Update exposing (update)
import View exposing (view)



---- PROGRAM ----


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Task.perform WindowSize Browser.Dom.getViewport )


main : Program () Model Msg
main =
    Browser.document
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Storage.load LoadGroup
        , Storage.saved SavedGroup
        , Browser.Events.onKeyDown (Decode.map KeyDown keyDecoder)
        ]


keyDecoder : Decode.Decoder Int
keyDecoder =
    Decode.field "keyCode" Decode.int
