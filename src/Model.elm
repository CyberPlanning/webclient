module Model exposing (..)

import String exposing(dropRight)
import Date
import Date.Extra as Dateextra
import Window

import Calendar.Msg
import Calendar.Calendar as Calendar

import Swipe

import Http exposing (Error)
import Types exposing (Query)

---- MODEL ----

type alias PlanningResponse =
    Result Error Query


type alias Model =
    { data : Maybe PlanningResponse --Maybe (Result String Query)
    , date : Maybe Date.Date
    , selectedGroup : Group
    , loading : Bool
    , size : Window.Size
    , calendarState : Calendar.State
    , swipe : Swipe.State
    }

type alias Group =
    { name : String
    , slug : String
    }

allGroups: List Group
allGroups =
    [ { name = "Cyber1 TD1", slug = "11" }
    , { name = "Cyber1 TD2", slug = "12" }
    , { name = "Cyber2 TD1", slug = "21" }
    , { name = "Cyber2 TD2", slug = "22" }
    , { name = "Cyber3 TD1", slug = "31" }
    , { name = "Cyber3 TD2", slug = "32" }
    ]

toDatetime : Date.Date -> String
toDatetime date =
    date
    |> Dateextra.add Dateextra.Hour -1
    |> Dateextra.toUtcIsoString
    |> dropRight 1
    -- Dateextra.toFormattedString "y-MM-ddTHH:mm:ss.000"


initialModel : Model
initialModel = 
    { data = Nothing
    , date = Nothing
    , selectedGroup = { name = "Cyber1 TD2", slug = "12" }
    , loading = False
    , calendarState = Calendar.init Calendar.Msg.Week ( Dateextra.fromParts 2018 Date.Jan 1 1 0 0 0 )
    , size = { width = 1200, height = 800 }
    , swipe = Swipe.init
    }
