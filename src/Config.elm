module Config exposing (..)

import Model exposing (Group)


apiUrl: String
apiUrl= "https://cyberplanning.fr/graphql/"


allGroups: List Group
allGroups =
    [ { name = "Cyber1 TD1", slug = "11" }
    , { name = "Cyber1 TD2", slug = "12" }
    , { name = "Cyber2 TD1", slug = "21" }
    , { name = "Cyber2 TD2", slug = "22" }
    , { name = "Cyber3 TD1", slug = "31" }
    , { name = "Cyber3 TD2", slug = "32" }
    ]