port module Storage exposing (Storage, saveEvents, saveGroup, saveSettings)

import Model
import Types


type alias Storage =
    { settings : Model.Settings
    , groupId : Int
    , offlineEvents : Types.Query
    }


port saveSettings : Model.Settings -> Cmd msg


port saveGroup : Int -> Cmd msg


port saveEvents : Types.Query -> Cmd msg
