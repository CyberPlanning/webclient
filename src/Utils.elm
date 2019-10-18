module Utils exposing (computeStyle, extractTimeIsoString, find, getGroup, getGroupId, initialModel, toCalEvents, toCalEventsWithSource, toDatetime)

import Calendar.Calendar as Calendar
import Calendar.Event as CalEvent
import Calendar.Helpers exposing (colorToHex, computeColor, noBright)
import Calendar.Msg
import Config exposing (allGroups, firstGroup)
import Iso8601
import Model exposing (Collection(..), Group, Model, Settings)
import Query.Types exposing (Event)
import Secret.Secret as Secret
import Set
import Storage
import Swipe
import Time exposing (Posix)


getGroupId : Group -> Int
getGroupId =
    .id


getGroup : Int -> Group
getGroup id =
    find (\x -> x.id == id) allGroups
        |> Maybe.withDefault firstGroup


toDatetime : Posix -> String
toDatetime =
    Iso8601.fromTime >> String.dropRight 14


initialModel : Storage.Storage -> Model
initialModel { settings, groupIds, offlineEvents } =
    let
        groups =
            List.map getGroup groupIds

        cyberEvents =
            offlineEvents.planning.events
                |> toCalEvents groups

        hack2g2Events =
            case offlineEvents.hack2g2 of
                Nothing ->
                    []

                Just p ->
                    p.events
                        |> toCalEventsWithSource "Hack2g2" "#00ff1d"

        customEvents =
            case offlineEvents.custom of
                Nothing ->
                    []

                Just p ->
                    p.events
                        |> toCalEventsWithSource "Custom" "#d82727"

        allEvents =
            cyberEvents
                ++ hack2g2Events
                ++ customEvents
    in
    { data = allEvents
    , error = Nothing
    , date = Nothing
    , loading = True
    , selectedGroups = groups
    , calendarState = Calendar.init Calendar.Msg.Week (Time.millisToPosix 0) (List.length groups)
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

        selectedGroupsSet =
            selectedGroups
                |> List.map .slug
                |> Set.fromList

        affiliations =
            event.affiliations
                |> Maybe.withDefault []
                |> Set.fromList
                |> Set.intersect selectedGroupsSet
                |> Set.toList

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
            if affiliationLen >= selectedLen || affiliationLen == 0 then
                CalEvent.All

            else
                CalEvent.Column firstAffIndex affiliationLen
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
