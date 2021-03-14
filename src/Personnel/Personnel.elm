module Personnel.Personnel exposing (Msg, State, getEvents, initState, restoreState, storeState, update, view)

import Calendar.Event as CalEvent
import File exposing (File)
import File.Select as Select
import Html exposing (Html, button, div, input, label, text)
import Html.Attributes exposing (checked, class, for, id, title, type_)
import Html.Events exposing (onCheck, onClick)
import MyTime
import Personnel.Ical exposing (VEvent, processIcal)
import Personnel.Storage exposing (decodeState, encodeState)
import Personnel.Types exposing (FileInfos, InternalState, defaultState)
import Task



-- STATE


type alias State =
    InternalState


initState : State
initState =
    defaultState



-- UPDATE


type Msg
    = FileSelected File
    | FileLoaded String
    | CheckActive Bool
    | RemoveFile


update : Msg -> State -> ( State, Cmd Msg )
update msg state =
    case msg of
        FileSelected file ->
            ( { state | file = Just (extractFileInfos file) }
            , Task.perform FileLoaded (File.toString file)
            )

        FileLoaded content ->
            ( { state | events = processIcal content |> personnelToEvents }
            , Cmd.none
            )

        CheckActive checked ->
            let
                action =
                    if checked && state.file == Nothing then
                        Select.file [ "text/calendar" ] FileSelected

                    else
                        Cmd.none
            in
            ( { state | active = checked }, action )

        RemoveFile ->
            ( { state | active = False, file = Nothing, events = [] }, Cmd.none )



-- VIEW


view : State -> Html Msg
view state =
    div
        []
        [ div [ class "md-checkbox" ]
            [ input [ id "check-personnel", type_ "checkbox", checked state.active, onCheck CheckActive ] []
            , label [ for "check-personnel" ] [ text "Load ICAL" ]
            ]
        , maybeViewFileInfos state.file
        ]


maybeViewFileInfos : Maybe FileInfos -> Html Msg
maybeViewFileInfos maybeFile =
    case maybeFile of
        Just file ->
            let
                year =
                    MyTime.toYear file.lastModified
                        |> String.fromInt

                month =
                    MyTime.toMonth file.lastModified
                        |> MyTime.monthToString
                        |> String.left 3

                day =
                    MyTime.toDay file.lastModified
                        |> String.fromInt
            in
            div
                [ onClick RemoveFile, title "Click to remove", class "personnel--fileinfo" ]
                [ div [] [ text (file.name ++ " : " ++ day ++ " " ++ month ++ " " ++ year) ]
                , div [] [ button [ class "personnel--fileinfo-remove" ] [ text "Remove" ] ]
                ]

        _ ->
            text ""



-- UTILS


extractFileInfos : File -> FileInfos
extractFileInfos file =
    { name = File.name file
    , lastModified = File.lastModified file
    }


personnelToEvents : List VEvent -> List CalEvent.Event
personnelToEvents vevents =
    List.map personnelToEvent vevents


personnelToEvent : VEvent -> CalEvent.Event
personnelToEvent vevent =
    { toId = vevent.summary
    , title = vevent.summary
    , startTime = vevent.dtstart
    , endTime = vevent.dtend
    , description = []
    , source = "Personnel"
    , style =
        { textColor = "orange"
        , eventColor = "black"
        }
    , position = CalEvent.All
    }



-- INTERFACE


getEvents : State -> List CalEvent.Event
getEvents { active, events } =
    if active then
        events

    else
        []



-- STORAGE


storeState : State -> String
storeState =
    encodeState


restoreState : String -> State
restoreState =
    decodeState
