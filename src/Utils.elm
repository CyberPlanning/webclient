module Utils exposing (computeStyle, extractTimeIsoString, find, getGroup, groupId, initialModel, toCalEvents, toCalEventsWithSource, toDatetime)

import Calendar.Calendar as Calendar
import Calendar.Event as CalEvent
import Calendar.Helpers exposing (colorToHex, computeColor, noBright)
import Calendar.Msg
import Config exposing (allGroups, firstGroup)
import Iso8601
import Model exposing (Collection(..), Group, Model, Settings)
import Secret
import Swipe
import Time exposing (Posix)
import Types exposing (Event)


groupId : Group -> Int
groupId =
    .id


getGroup : Int -> Group
getGroup id =
    find (\x -> x.id == id) allGroups
        |> Maybe.withDefault firstGroup


toDatetime : Posix -> String
toDatetime =
    Iso8601.fromTime >> String.dropRight 14


initialModel : Settings -> Int -> Model
initialModel settings id =
    let
        group =
            getGroup id
    in
    { data = Nothing
    , error = Nothing
    , date = Nothing
    , loading = True
    , selectedGroups = [ group ]
    , selectedCollection = Cyber
    , calendarState = Calendar.init Calendar.Msg.Week (Time.millisToPosix 0)
    , size = { width = 1200, height = 800 }
    , swipe = Swipe.init
    , loop = False
    , secret = Secret.createStates
    , settings = settings
    , tooltipHover = False
    }


toCalEvents : List Group -> List Event -> List CalEvent.Event
toCalEvents selectedGroups events =
    List.map (toCalEvent selectedGroups) events


toCalEventsWithSource : String -> String -> List Event -> List CalEvent.Event
toCalEventsWithSource source color events =
    List.map (toCalEventSource source color) events


toCalEvent : List Group -> Event -> CalEvent.Event
toCalEvent selectedGroups event =
    let
        classes =
            Maybe.withDefault [] event.classrooms

        teachers =
            Maybe.withDefault [] event.teachers

        groups =
            Maybe.withDefault [] event.groups

        affiliations =
            Maybe.withDefault [] event.affiliations

        description =
            List.map (String.join ", ") [ classes, teachers, groups ]

        search1 =
            List.foldl (\a b -> b && String.contains "1" a) True affiliations

        search2 =
            List.foldl (\a b -> b && String.contains "2" a) True affiliations

        selectedLen =
            List.length selectedGroups

        affiliationLen =
            List.length affiliations

        firstAff =
            List.head affiliations
                |> Maybe.withDefault "11"

        firstAffIndex =
            List.map .slug selectedGroups
                |> List.indexedMap Tuple.pair
                |> find (\x -> Tuple.second x == firstAff)
                |> Maybe.withDefault ( 0, "" )
                |> Tuple.first

        position =
            if affiliationLen == selectedLen || affiliationLen == 0 then
                CalEvent.All

            else
                CalEvent.Column firstAffIndex selectedLen
    in
    { toId = event.eventId
    , title = event.title
    , startTime = extractTimeIsoString event.startDate
    , endTime = extractTimeIsoString event.endDate
    , description = description
    , style = computeStyle event.title
    , source = ""
    , position = position
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
    , position = CalEvent.All
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
