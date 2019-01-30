module Utils exposing (computeStyle, extractTimeIsoString, find, initialModel, toCalEvents, toCalEventsWithSource, toDatetime)

import Calendar.Calendar as Calendar
import Calendar.Event as CalEvent
import Calendar.Helpers exposing (colorToHex, computeColor, noBright)
import Calendar.Msg
import Config exposing (allGroups)
import Iso8601
import Model exposing (Model, Settings)
import Secret
import Swipe
import Time exposing (Posix)
import Types exposing (Event)


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


toCalEventsWithSource : String -> String -> List Event -> List CalEvent.Event
toCalEventsWithSource source color events =
    List.map (toCalEventSource source color) events


toCalEvent : Event -> CalEvent.Event
toCalEvent event =
    let
        classes =
            Maybe.withDefault [] event.classrooms

        teachers =
            Maybe.withDefault [] event.teachers

        groups =
            Maybe.withDefault [] event.groups

        description =
            List.map (String.join ", ") [ classes, teachers, groups ]
    in
    { toId = event.eventId
    , title = event.title
    , startTime = extractTimeIsoString event.startDate
    , endTime = extractTimeIsoString event.endDate
    , description = description
    , style = computeStyle event.title
    , source = ""
    }


toCalEventSource : String -> String -> Event -> CalEvent.Event
toCalEventSource source color event =
    let
        classes =
            Maybe.withDefault [] event.classrooms

        teachers =
            Maybe.withDefault [] event.teachers

        groups =
            Maybe.withDefault [] event.groups

        description =
            List.map (String.join ", ") [ classes, teachers, groups ]
    in
    { toId = event.eventId
    , title = event.title
    , startTime = extractTimeIsoString event.startDate
    , endTime = extractTimeIsoString event.endDate
    , description = description
    , source = source
    , style =
        { textColor = color
        , eventColor = "black"
        }
    }


computeStyle : String -> CalEvent.Style
computeStyle val =
    { textColor = "white"
    , eventColor = computeColor val
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
