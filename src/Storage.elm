port module Storage exposing (Storage, save)

import Model


type alias Storage =
    { groupId : Int
    , settings : Model.Settings
    }


port save : Storage -> Cmd msg
