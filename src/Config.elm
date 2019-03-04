module Config exposing (allGroups, firstGroup, apiUrl, minWeekWidth)

import Model exposing (Collection(..), Group)


apiUrl : String
apiUrl =
    "https://cyberplanning.fr/graphql/"


allGroups : List Group
allGroups =
    [ { name = "Cyber1 TD1", slug = "11", collection = Cyber }
    , { name = "Cyber1 TD2", slug = "12", collection = Cyber }
    , { name = "Cyber2 TD1", slug = "21", collection = Cyber }
    , { name = "Cyber2 TD2", slug = "22", collection = Cyber }
    , { name = "Cyber3 TD1", slug = "31", collection = Cyber }
    , { name = "Info1 TD1", slug = "11", collection = Info }
    , { name = "Info1 TD2", slug = "12", collection = Info }
    , { name = "Info2 TD1", slug = "21", collection = Info }
    , { name = "Info2 TD2", slug = "22", collection = Info }
    , { name = "Info3", slug = "31", collection = Info }
    ]


firstGroup : Group
firstGroup =
    { name = "Cyber1 TD1", slug = "11", collection = Cyber }


minWeekWidth : Int
minWeekWidth =
    660
