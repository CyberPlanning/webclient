port module Storage exposing (Storage, saveEvents, saveGroups, saveSettings)

import Model
import Types


type alias Storage =
    { settings : Model.Settings
    , groupIds : List Int
    , offlineEvents : Types.Query
    }


port saveSettings : Model.Settings -> Cmd msg


port saveGroups : List Int -> Cmd msg


port saveEvents : Types.Query -> Cmd msg
