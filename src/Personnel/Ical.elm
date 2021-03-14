module Personnel.Ical exposing (VCalendar, VEvent, processIcal, emptyVCalendar, emptyVEvent)

import Array
import Time exposing (Posix)
import Personnel.Timeparser exposing (toTime)


type alias VCalendar =
    { events : List VEvent
    , working : Bool
    , parsing : VEvent
    }


type alias VEvent =
    { summary : String
    , dtstart : Posix
    , dtend : Posix
    }


epoch : Posix
epoch =
    Time.millisToPosix 10000


processIcal : String -> List VEvent
processIcal data =
    data
        |> String.split "\n"
        |> parseCalendar
        |> .events


emptyVCalendar : VCalendar
emptyVCalendar =
    { events = []
    , working = False
    , parsing = emptyVEvent
    }


emptyVEvent : VEvent
emptyVEvent =
    { summary = ""
    , dtstart = epoch
    , dtend = epoch
    }


parseCalendar : List String -> VCalendar
parseCalendar lines =
    List.foldl innerParseCalendar emptyVCalendar lines


innerParseCalendar : String -> VCalendar -> VCalendar
innerParseCalendar line cal =
    let
        lineTrim = String.trim line

        parts =
            lineTrim
                |> String.trim
                |> String.split ":"
                |> Array.fromList

        key =
            Array.get 0 parts
                |> Maybe.andThen parseVKey
                |> Maybe.withDefault ""

        value =
            Array.get 1 parts
                |> Maybe.withDefault ""
    in
    case lineTrim of
        "BEGIN:VEVENT" ->
            { cal | working = True }

        "END:VEVENT" ->
            { cal | working = False, events = cal.parsing :: cal.events, parsing = emptyVEvent }

        _ ->
            let
                parsing =
                    cal.parsing

                event =
                    case key of
                        "SUMMARY" ->
                            { parsing | summary = value }

                        "DTSTART" ->
                            { parsing | dtstart = parseCalDatetime value }

                        "DTEND" ->
                            { parsing | dtend = parseCalDatetime value }

                        _ ->
                            parsing
            in
            { cal | parsing = event }


parseCalDatetime : String -> Posix
parseCalDatetime value =
    case toTime value of
        Ok time ->
            time

        Err _ ->
            -- let
            --     a =
            --         Debug.log "Parsing errors" errors
            --     b =
            --         Debug.log "value" value
            -- in
            Time.millisToPosix 0


parseVKey : String -> Maybe String
parseVKey key =
    key
        |> String.split ";"
        |> List.head
