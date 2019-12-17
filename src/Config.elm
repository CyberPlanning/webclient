module Config exposing (allGroups, apiUrl, firstGroup, minWeekWidth, enableEasterEgg, enablePersonnelCal)

import Cyberplanning.Types exposing (Collection(..), Group)


enableEasterEgg : Bool
enableEasterEgg =
    False


enablePersonnelCal : Bool
enablePersonnelCal =
    False


apiUrl : String
apiUrl =
    -- "http://localhost:3001/graphql/"
    "https://cyberplanning.fr/graphql/"


allGroups : List Group
allGroups =
    [ { name = "Cyber1 TD1 TP1", slug = "111", collection = Cyber, id = 0 }
    , { name = "Cyber1 TD1 TP2", slug = "112", collection = Cyber, id = 1 }
    , { name = "Cyber1 TD2 TP3", slug = "121", collection = Cyber, id = 2 }
    , { name = "Cyber1 TD2 TP4", slug = "122", collection = Cyber, id = 3 }
    , { name = "Cyber2 TD1 TP1", slug = "211", collection = Cyber, id = 4 }
    , { name = "Cyber2 TD1 TP2", slug = "212", collection = Cyber, id = 5 }
    , { name = "Cyber2 TD2 TP3", slug = "221", collection = Cyber, id = 6 }
    , { name = "Cyber2 TD2 TP4", slug = "222", collection = Cyber, id = 7 }
    , { name = "Cyber3 TD1 TP1", slug = "311", collection = Cyber, id = 8 }
    , { name = "Cyber3 TD1 TP2", slug = "312", collection = Cyber, id = 9 }
    , { name = "Cyber3 TD2 TP3", slug = "321", collection = Cyber, id = 10 }
    , { name = "Cyber3 TD2 TP4", slug = "322", collection = Cyber, id = 11 }
    , { name = "Info1 TP1", slug = "111", collection = Info, id = 12 }
    , { name = "Info1 TP2", slug = "121", collection = Info, id = 13 }
    , { name = "Info2 TP1", slug = "211", collection = Info, id = 14 }
    , { name = "Info2 TP2", slug = "221", collection = Info, id = 15 }
    , { name = "Info3 TP1", slug = "311", collection = Info, id = 16 }
    , { name = "Info3 TP2", slug = "321", collection = Info, id = 17 }
    ]


firstGroup : Group
firstGroup =
    { name = "Cyber1 TD1 TP1", slug = "111", collection = Cyber, id = 0 }


minWeekWidth : Int
minWeekWidth =
    660
