module Utils exposing (extractTimeIsoString, find, initialModel, toCalEvents, toDatetime)

import Iso8601
import Model exposing (Settings, Model)
import Config exposing (allGroups)
import Secret
import Swipe
import Types exposing (Event)
import Time exposing (Posix)
import Calendar.Calendar as Calendar
import Calendar.Event as CalEvent
import Calendar.Helpers exposing (colorToHex, computeColor, noBright)
import Calendar.Msg


toDatetime : Posix -> String
toDatetime =
    Iso8601.fromTime >> String.dropRight 14


initialModel : Settings -> String -> Model
initialModel settings slug =
    let
        group =
            find (\x -> x.slug == slug) allGroups
                |> Maybe.withDefault { slug = "12", name = "Cyber1 TD2" }
    in
    { data = Nothing
    , error = Nothing
    , date = Nothing
    , loading = True
    , selectedGroup = group
    , calendarState = Calendar.init Calendar.Msg.Week (Time.millisToPosix 0)
    , size = { width = 1200, height = 800 }
    , swipe = Swipe.init
    , loop = False
    , secret = Secret.createStates
    , settings = settings
    , tooltipHover = False
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
    , locations = Maybe.withDefault [] event.classrooms
    , stakeholders = Maybe.withDefault [] event.teachers
    , groups = Maybe.withDefault [] event.groups
    , color = computeColor event.title
    }


extractTimeIsoString : String -> Posix
extractTimeIsoString dateString =
    dateString
        ++ ".000Z"
        |> Iso8601.toTime
        |> Result.withDefault (Time.millisToPosix 0)


find : (a -> Bool) -> List a -> Maybe a
find predicate list =
    case list of
        [] ->
            Nothing

        first :: rest ->
            if predicate first then
                Just first

            else
                find predicate rest
