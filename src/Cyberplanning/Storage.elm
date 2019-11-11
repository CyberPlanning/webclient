module Cyberplanning.Storage exposing (decodeState, encodeState)

import Calendar.Event as CalEvent
import Config exposing (firstGroup)
import Cyberplanning.Types exposing (Collection(..), FetchStatus(..), Group, InternalState, Settings, defaultSettings)
import Json.Decode as D
import Json.Encode as E
import Time


type alias JsonPosition =
    { value : String
    , param1 : Int
    , param2 : Int
    }



-- ENCODE


encodeState : InternalState -> String
encodeState state =
    encoder state
        |> E.encode 0


encoder : InternalState -> E.Value
encoder state =
    E.object
        [ ( "events", E.list encoderEvent state.events )
        , ( "settings", encoderSettings state.settings )
        , ( "selectedGroups", E.list encoderGroup state.selectedGroups )
        ]


encoderSettings : Settings -> E.Value
encoderSettings settings =
    E.object
        [ ( "showHack2g2", E.bool settings.showHack2g2 )
        , ( "showCustom", E.bool settings.showCustom )
        ]


encoderGroup : Group -> E.Value
encoderGroup group =
    E.object
        [ ( "name", E.string group.name )
        , ( "slug", E.string group.slug )
        , ( "collection", encoderCollection group.collection )
        , ( "id", E.int group.id )
        ]


encoderCollection : Collection -> E.Value
encoderCollection collection =
    case collection of
        Cyber ->
            E.string "Cyber"

        Info ->
            E.string "Info"


encoderEvent : CalEvent.Event -> E.Value
encoderEvent event =
    E.object
        [ ( "toId", E.string event.toId )
        , ( "title", E.string event.title )
        , ( "startTime", E.int (Time.posixToMillis event.startTime) )
        , ( "endTime", E.int (Time.posixToMillis event.endTime) )
        , ( "description", E.list E.string event.description )
        , ( "source", E.string event.source )
        , ( "style", encoderStyle event.style )
        , ( "position", encoderPosition event.position )
        ]


encoderStyle : CalEvent.Style -> E.Value
encoderStyle style =
    E.object
        [ ( "eventColor", E.string style.eventColor )
        , ( "textColor", E.string style.textColor )
        ]


encoderPosition : CalEvent.PositionMode -> E.Value
encoderPosition position =
    case position of
        CalEvent.All ->
            E.object
                [ ( "value", E.string "All" )
                ]

        CalEvent.Column p1 p2 ->
            E.object
                [ ( "value", E.string "Column" )
                , ( "param1", E.int p1 )
                , ( "param2", E.int p2 )
                ]



-- DECODER
-- debugError : Result err value -> Result err value
-- debugError res =
--     case res of
--         Ok _ ->
--             res
--         Err erros ->
--             let
--                 a =
--                     Debug.log "Error" erros
--             in
--             res


type alias StorageState =
    { events : List CalEvent.Event
    , selectedGroups : List Group
    , settings : Settings
    }


defaultState : StorageState
defaultState =
    { events = []
    , selectedGroups = [ firstGroup ]
    , settings = defaultSettings
    }


decodeState : String -> InternalState
decodeState value =
    let
        state =
            D.decodeString decoder value
                -- |> debugError
                |> Result.withDefault defaultState
    in
    { events = state.events
    , selectedGroups = state.selectedGroups
    , groupsCount = List.length state.selectedGroups
    , status = Normal
    , settings = state.settings
    }


decoder : D.Decoder StorageState
decoder =
    D.map3 StorageState
        (D.field "events" (D.list decoderEvent))
        (D.field "selectedGroups" (D.list decoderGroup))
        (D.field "settings" decoderSettings)


decoderSettings : D.Decoder Settings
decoderSettings =
    D.map2 Settings
        (D.field "showHack2g2" D.bool)
        (D.field "showCustom" D.bool)


decoderGroup : D.Decoder Group
decoderGroup =
    D.map4 Group
        (D.field "name" D.string)
        (D.field "slug" D.string)
        (D.field "collection" decoderCollection)
        (D.field "id" D.int)


decoderCollection : D.Decoder Collection
decoderCollection =
    D.string
        |> D.andThen
            (\str ->
                case str of
                    "Cyber" ->
                        D.succeed Cyber

                    "Info" ->
                        D.succeed Info

                    somethingElse ->
                        D.fail <| "Unknown collection: " ++ somethingElse
            )


decoderEvent : D.Decoder CalEvent.Event
decoderEvent =
    D.map8 CalEvent.Event
        (D.field "toId" D.string)
        (D.field "title" D.string)
        (D.field "startTime" (D.int |> D.andThen (Time.millisToPosix >> D.succeed)))
        (D.field "endTime" (D.int |> D.andThen (Time.millisToPosix >> D.succeed)))
        (D.field "description" (D.list D.string))
        (D.field "source" D.string)
        (D.field "style" decoderStyle)
        (D.field "position" decoderPosition)


decoderStyle : D.Decoder CalEvent.Style
decoderStyle =
    D.map2 CalEvent.Style
        (D.field "eventColor" D.string)
        (D.field "textColor" D.string)


decoderPosition : D.Decoder CalEvent.PositionMode
decoderPosition =
    decoderJsonPosition
        |> D.andThen
            (\entrie ->
                case entrie.value of
                    "All" ->
                        D.succeed CalEvent.All

                    "Column" ->
                        D.succeed (CalEvent.Column entrie.param1 entrie.param2)

                    somethingElse ->
                        D.fail <| "Unknown position: " ++ somethingElse
            )


decoderJsonPosition : D.Decoder JsonPosition
decoderJsonPosition =
    D.map3 JsonPosition
        (D.field "value" D.string)
        (decoderJsonPositionParam "param1" 0)
        (decoderJsonPositionParam "param2" 1)


decoderJsonPositionParam : String -> Int -> D.Decoder Int
decoderJsonPositionParam name default =
    D.maybe (D.field name D.int)
        |> D.andThen (Maybe.withDefault default >> D.succeed)
