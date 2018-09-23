module Calendar.Msg exposing (Msg(..), TimeSpan(..))

import Time exposing (Posix)


type TimeSpan
    = Week
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
