port module Storage exposing (save, Storage)

import Model


type alias Storage =
    { group : String
    , settings : Model.Settings
    }


port save : Storage -> Cmd msg
