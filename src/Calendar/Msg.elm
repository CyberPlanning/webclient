module Calendar.Msg exposing (..)

import Date exposing(Date)

type TimeSpan
    = Week
    | Day


type Msg
    = PageBack
    | PageForward
    | WeekForward
    | WeekBack
    | ChangeTimeSpan TimeSpan
    | ChangeViewing Date
    | EventClick String
    | EventMouseEnter String
    | EventMouseLeave String
