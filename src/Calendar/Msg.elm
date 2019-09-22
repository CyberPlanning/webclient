module Calendar.Msg exposing (InternalState, Msg(..), Position, TimeSpan(..), onClick, onMouseEnter, position)

import Dict exposing (Dict)
import Html exposing (Attribute)
import Html.Events exposing (on)
import Json.Decode as Json
import Time exposing (Posix)


type TimeSpan
    = Week
    | AllWeek
    | Day


type Msg
    = PageBack
    | PageForward
    | WeekForward
    | WeekBack
    | SetColumns Int
    | ChangeTimeSpan TimeSpan
    | ChangeViewing Posix
    | EventClick String Position
    | EventMouseEnter String Position
    | EventMouseLeave String


type alias InternalState =
    { timeSpan : TimeSpan
    , viewing : Posix
    , hover : Maybe String
    , position : Maybe Position
    , selected : Maybe String
    , columns : Int
    , joursFeries : Dict String Posix
    }


type alias Position =
    { x : Int
    , y : Int
    }


{-| The decoder used to extract a `Position` from a JavaScript mouse event.
-}
position : Json.Decoder Position
position =
    Json.map2 Position
        (Json.field "pageX" Json.int)
        (Json.field "pageY" Json.int)


onMouseEnter : (Position -> msg) -> Attribute msg
onMouseEnter msg =
    on "mouseenter" (Json.map msg position)


onClick : (Position -> msg) -> Attribute msg
onClick msg =
    on "click" (Json.map msg position)
