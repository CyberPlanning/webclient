module Config exposing (allGroups, apiUrl, firstGroup, minWeekWidth)

import Model exposing (Collection(..), Group)


apiUrl : String
apiUrl =
    -- "http://localhost:3001/graphql/"
    "https://cyberplanning.fr/graphql/"


allGroups : List Group
allGroups =
    [ { name = "Cyber1 TD1", slug = "11", collection = Cyber, id = 0 }
    , { name = "Cyber1 TD2", slug = "12", collection = Cyber, id = 1 }
    , { name = "Cyber2 TD1", slug = "21", collection = Cyber, id = 2 }
    , { name = "Cyber2 TD2", slug = "22", collection = Cyber, id = 3 }
    , { name = "Cyber3 TD1", slug = "31", collection = Cyber, id = 4 }
    , { name = "Info1 TD1", slug = "11", collection = Info, id = 5 }
    , { name = "Info1 TD2", slug = "12", collection = Info, id = 6 }
    , { name = "Info2 TD1", slug = "21", collection = Info, id = 7 }
    , { name = "Info2 TD2", slug = "22", collection = Info, id = 8 }
    , { name = "Info3", slug = "31", collection = Info, id = 9 }
    ]


firstGroup : Group
firstGroup =
    { name = "Cyber1 TD1", slug = "11", collection = Cyber, id = 0 }


minWeekWidth : Int
minWeekWidth =
    660
