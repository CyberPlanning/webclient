port module Storage exposing (Storage, saveEvents, saveGroups, saveSettings)

import Model
import Query.Types


type alias Storage =
    { settings : Model.Settings
    , groupIds : List Int
    , offlineEvents : Query.Types.Query
    }


port saveSettings : Model.Settings -> Cmd msg


port saveGroups : List Int -> Cmd msg


port saveEvents : Query.Types.Query -> Cmd msg
