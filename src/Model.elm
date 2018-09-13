module Model exposing (Group, Model, PlanningResponse, WindowSize, computeColor, initialModel, parseDateEvent, toCalEvent, toCalEvents, toDatetime)

import Calendar.Calendar as Calendar
import Calendar.Event as CalEvent
import Calendar.Helpers exposing (colorToHex, noBright)
import Calendar.Msg
import Color
import Date
import Hex
import Http exposing (Error)
import MD5
import Secret
import String exposing (dropRight)
import Swipe
import Time
import Types exposing (Event, Query)



---- MODEL ----


type alias PlanningResponse =
    Result Error Query


type alias WindowSize =
    { width : Int
    , height : Int
    }


type alias Model =
    { data : Maybe (List CalEvent.Event) --Maybe (Result String Query)
    , error : Maybe Error
    , date : Maybe Date.Date
    , selectedGroup : Group
    , loading : Bool
    , size : WindowSize
    , calendarState : Calendar.State
    , swipe : Swipe.State
    , loop : Bool
    , secret : Secret.StateList
    }


type alias Group =
    { name : String
    , slug : String
    }


toDatetime : Date.Date -> String
toDatetime =
    Date.toIsoString



initialModel : Model
initialModel =
    { data = Nothing
    , error = Nothing
    , date = Nothing
    , selectedGroup = { name = "Cyber1 TD2", slug = "12" }
    , loading = True
    , calendarState = Calendar.init Calendar.Msg.Week (Date.fromCalendarDate 2018 Time.Jan 1)
    , size = { width = 1200, height = 800 }
    , swipe = Swipe.init
    , loop = False
    , secret = Secret.createStates
    }


toCalEvents : List Event -> List CalEvent.Event
toCalEvents events =
    List.map toCalEvent events


toCalEvent : Event -> CalEvent.Event
toCalEvent event =
    { toId = event.eventId
    , title = event.title
    , start = parseDateEvent event.startDate
    , startTime = extractTimeIsoString event.startDate
    , end = parseDateEvent event.endDate
    , endTime = extractTimeIsoString event.endDate
    , classrooms = event.classrooms
    , teachers = event.teachers
    , groups = event.groups
    , color = computeColor event.title
    }


parseDateEvent : String -> Date.Date
parseDateEvent date =
    date
        |> String.dropRight 9
        |> Date.fromIsoString
        |> Result.withDefault (Date.fromOrdinalDate 0 0)


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


extractTimeIsoString : String -> Int
extractTimeIsoString dateString =
    let
        timeString =
            dateString
                |> String.dropLeft 11

        hours =
            timeString
                |> String.dropRight 6
                |> String.toInt
                |> Maybe.withDefault 0
                -- TODO better work with time zone
                |> (+) 2

        minutes =
            timeString
                |> String.dropRight 3
                |> String.dropLeft 3
                |> String.toInt
                |> Maybe.withDefault 0

        seconds =
            timeString
                |> String.dropLeft 6
                |> String.toInt
                |> Maybe.withDefault 0
    in
    hours * 3600 + minutes * 60 + seconds
