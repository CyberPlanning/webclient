module Calendar.Msg exposing (InternalState, Msg(..), TimeSpan(..))

import Dict exposing (Dict)
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
    | ChangeTimeSpan TimeSpan
    | ChangeViewing Posix
    | EventClick String
    | EventMouseEnter String
    | EventMouseLeave String


type alias InternalState =
    { timeSpan : TimeSpan
    , viewing : Posix
    , hover : Maybe String
    , selected : Maybe String
    , joursFeries : Dict String Posix
    }
