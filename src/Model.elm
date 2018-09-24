module Model exposing (Group, Model, PlanningResponse, WindowSize, initialModel, toCalEvent, toCalEvents, toDatetime)

import Calendar.Calendar as Calendar
import Calendar.Event as CalEvent
import Calendar.Helpers exposing (colorToHex, computeColor, noBright)
import Calendar.Msg
import Color
import Http exposing (Error)
import Iso8601
import Secret
import String exposing (dropRight)
import Swipe
import Time exposing (Posix)
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
    , date : Maybe Posix
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


toDatetime : Posix -> String
toDatetime =
    Iso8601.fromTime >> String.dropRight 14


initialModel : Model
initialModel =
    { data = Nothing
    , error = Nothing
    , date = Nothing
    , selectedGroup = { name = "Cyber1 TD2", slug = "12" }
    , loading = True
    , calendarState = Calendar.init Calendar.Msg.Week (Time.millisToPosix 0)
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
    , startTime = extractTimeIsoString event.startDate
    , endTime = extractTimeIsoString event.endDate
    , classrooms = event.classrooms
    , teachers = event.teachers
    , groups = event.groups
    , color = computeColor event.title
    }


extractTimeIsoString : String -> Posix
extractTimeIsoString dateString =
    dateString
        ++ ".000Z"
        |> Iso8601.toTime
        |> Result.withDefault (Time.millisToPosix 0)



-- let
--     timeString =
--         dateString
--             |> String.dropLeft 11
--     hours =
--         timeString
--             |> String.dropRight 6
--             |> String.toInt
--             |> Maybe.withDefault 0
--             -- TODO better work with time zone
--             |> (+) 2
--     minutes =
--         timeString
--             |> String.dropRight 3
--             |> String.dropLeft 3
--             |> String.toInt
--             |> Maybe.withDefault 0
--     seconds =
--         timeString
--             |> String.dropLeft 6
--             |> String.toInt
--             |> Maybe.withDefault 0
-- in
-- hours * 3600 + minutes * 60 + seconds
