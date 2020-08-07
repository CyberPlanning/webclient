module Main exposing (main)

import Browser
import Browser.Dom
import Browser.Events
import Browser.Navigation as Nav
import Json.Decode as Decode
import Model exposing (Model)
import Msg exposing (Msg(..))
import Storage
import Task
import Update exposing (update)
import Utils exposing (initialModel)
import View.View exposing (view)
import Url



---- PROGRAM ----


init : Storage.Storage -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init storage url navKey=
    ( initialModel storage url navKey, Task.perform WindowSize Browser.Dom.getViewport )


main : Program Storage.Storage Model Msg
main =
    Browser.application
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = \_ -> Noop
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Browser.Events.onKeyDown (Decode.map KeyDown keyDecoder)


keyDecoder : Decode.Decoder Int
keyDecoder =
    Decode.field "keyCode" Decode.int
