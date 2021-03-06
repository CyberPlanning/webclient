module Vendor.Swipe exposing
    ( Coordinates
    , Direction(..)
    , Msg
    , State
    , SwipeState(..)
    , hasSwiped
    , init
    , onSwipe
    , update
    )

import Html
import Html.Events as Events
import Json.Decode as Decode exposing (Decoder)


type Msg
    = Start Touch
    | Move Touch
    | End Touch
    | Cancel Touch


type alias State =
    { c0 : Coordinates
    , c1 : Coordinates
    , id : Int
    , direction : Maybe Direction
    , state : SwipeState
    }


type SwipeState
    = SwipeStart
    | Swiping
    | SwipeEnd


type alias Touch =
    { identifier : Int
    , coordinates : Coordinates
    }


type alias Coordinates =
    { clientX : Float
    , clientY : Float
    }


type Direction
    = Left
    | Right


init : State
init =
    { c0 = emptyCoordinates
    , c1 = emptyCoordinates
    , id = 0
    , direction = Nothing
    , state = SwipeEnd
    }


update : Msg -> State -> State
update msg state =
    case msg of
        Start touch ->
            { c0 = touch.coordinates
            , c1 = emptyCoordinates
            , id = touch.identifier
            , direction = Nothing
            , state = SwipeStart
            }

        Move touch ->
            let
                dir =
                    direction <| subCoordinates touch.coordinates state.c0
            in
            { state | direction = dir, c1 = touch.coordinates, id = touch.identifier, state = Swiping }

        End touch ->
            let
                dir =
                    direction <| subCoordinates touch.coordinates state.c0
            in
            { state | direction = dir, c1 = touch.coordinates, id = touch.identifier, state = SwipeEnd }

        Cancel touch ->
            { c0 = touch.coordinates
            , c1 = emptyCoordinates
            , id = touch.identifier
            , direction = Nothing
            , state = SwipeEnd
            }


hasSwiped : State -> Float -> Maybe Direction
hasSwiped state distance =
    if (state.state == SwipeEnd) && (distanceX state.c0 state.c1 > distance) then
        state.direction

    else
        Nothing


direction : Coordinates -> Maybe Direction
direction { clientX, clientY } =
    if clientX > 0 then
        Just Right

    else if clientX < 0 then
        Just Left

    else
        Nothing


distanceX : Coordinates -> Coordinates -> Float
distanceX c0 c1 =
    abs (c0.clientX - c1.clientX)


subCoordinates : Coordinates -> Coordinates -> Coordinates
subCoordinates a b =
    { clientX = a.clientX - b.clientX
    , clientY = a.clientY - b.clientY
    }


emptyCoordinates : Coordinates
emptyCoordinates =
    { clientX = 0.0
    , clientY = 0.0
    }



-- TOUCH EVENTS ##################################################


onSwipe : (Msg -> msg) -> List (Html.Attribute msg)
onSwipe tag =
    [ onStart Start tag

    -- , onMove Move tag
    , onEnd End tag

    -- , onCancel Cancel tag
    ]


onStart : (Touch -> Msg) -> (Msg -> msg) -> Html.Attribute msg
onStart tag =
    on "touchstart" tag


onMove : (Touch -> Msg) -> (Msg -> msg) -> Html.Attribute msg
onMove tag =
    on "touchmove" tag


onEnd : (Touch -> Msg) -> (Msg -> msg) -> Html.Attribute msg
onEnd tag =
    on "touchend" tag


onCancel : (Touch -> Msg) -> (Msg -> msg) -> Html.Attribute msg
onCancel tag =
    on "touchcancel" tag



-- HELPER FUNCTIONS ##################################################
-- stopOptions : Events.Options
-- stopOptions =
--     { stopPropagation = False
--     , preventDefault = False
--     }


on : String -> (Touch -> Msg) -> (Msg -> msg) -> Html.Attribute msg
on event msg tag =
    -- Decoder Msg
    Decode.map msg decodeCoordinates
        -- Decoder msg
        |> Decode.map tag
        -- Decoder (msg, Bool)
        |> Decode.map (\m -> ( m, True ))
        |> Events.stopPropagationOn event


decodeCoordinates : Decoder Touch
decodeCoordinates =
    decode
        |> Decode.at [ "changedTouches", "0" ]


decode : Decoder Touch
decode =
    Decode.map2 Touch
        (Decode.field "identifier" Decode.int)
        (Decode.map2 Coordinates
            (Decode.field "clientX" Decode.float)
            (Decode.field "clientY" Decode.float)
        )
