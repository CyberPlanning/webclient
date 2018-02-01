module Model exposing (..)

import String exposing(dropRight)
import Date
import Date.Extra as Dateextra
import Window
import Color exposing (Color)
import Hex
import MD5

import Calendar.Msg
import Calendar.Calendar as Calendar
import Calendar.Event as CalEvent

import Swipe

import Http exposing (Error)
import Types exposing (Query, Event)

---- MODEL ----

type alias PlanningResponse =
    Result Error Query


type alias Model =
    { data : Maybe (List CalEvent.Event) --Maybe (Result String Query)
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

toCalEvents : List Event -> List CalEvent.Event
toCalEvents events =
    List.map toCalEvent events


toCalEvent : Event -> CalEvent.Event
toCalEvent event =
        { toId = event.eventId
        , title = event.title
        , start = parseDateEvent event.startDate
        , end = parseDateEvent event.endDate
        , classrooms = event.classrooms
        , teachers = event.teachers
        , groups = event.groups
        , color = computeColor event.title
        }


parseDateEvent: String -> Date.Date
parseDateEvent date =
    date ++ "Z"
    |> Dateextra.fromIsoString
    |> Maybe.withDefault (Date.fromTime 0)


computeColor : String -> Color
computeColor text =
    let
        hex = MD5.hex text
            |> String.right 6

        red = String.slice 0 2 hex
            |> Hex.fromString
            |> Result.withDefault 0

        green = String.slice 2 4 hex
            |> Hex.fromString
            |> Result.withDefault 0

        blue = String.slice 4 6 hex
            |> Hex.fromString
            |> Result.withDefault 0
    in
        Color.rgb red green blue

