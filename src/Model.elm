module Model exposing (Group, Model, PlanningResponse, computeColor, initialModel, parseDateEvent, toCalEvent, toCalEvents, toDatetime)

import Calendar.Calendar as Calendar
import Calendar.Event as CalEvent
import Calendar.Helpers exposing (colorToHex, noBright)
import Calendar.Msg
import Color exposing (Color)
import Date
import Date.Extra as Dateextra
import Hex
import Http exposing (Error)
import MD5
import Secret
import String exposing (dropRight)
import Swipe
import Types exposing (Event, Query)
import Window



---- MODEL ----


type alias PlanningResponse =
    Result Error Query


type alias Model =
    { data : Maybe (List CalEvent.Event) --Maybe (Result String Query)
    , error : Maybe Error
    , date : Maybe Date.Date
    , selectedGroup : Group
    , loading : Bool
    , size : Window.Size
    , calendarState : Calendar.State
    , swipe : Swipe.State
    , loop : Bool
    , secret1 : Secret.State
    , secret2 : Secret.State
    }


type alias Group =
    { name : String
    , slug : String
    }


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
    , error = Nothing
    , date = Nothing
    , selectedGroup = { name = "Cyber1 TD2", slug = "12" }
    , loading = True
    , calendarState = Calendar.init Calendar.Msg.Week (Dateextra.fromParts 2018 Date.Jan 1 1 0 0 0)
    , size = { width = 1200, height = 800 }
    , swipe = Swipe.init
    , loop = False
    , secret1 = Secret.createState1
    , secret2 = Secret.createState2
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


parseDateEvent : String -> Date.Date
parseDateEvent date =
    date
        ++ "Z"
        |> Dateextra.fromIsoString
        |> Result.withDefault (Date.fromTime 0)


computeColor : String -> String
computeColor text =
    let
        hex =
            String.dropRight 1 text
                |> MD5.hex
                |> String.right 6

        red =
            String.slice 0 2 hex
                |> Hex.fromString
                |> Result.withDefault 0

        green =
            String.slice 2 4 hex
                |> Hex.fromString
                |> Result.withDefault 0

        blue =
            String.slice 4 6 hex
                |> Hex.fromString
                |> Result.withDefault 0
    in
    Color.rgb red green blue
        |> noBright
        |> colorToHex
