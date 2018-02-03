module Calendar.Msg exposing (..)

type TimeSpan
    = Week
    | Day


type Msg
    = PageBack
    | PageForward
    | WeekForward
    | WeekBack
    | ChangeTimeSpan TimeSpan
    | EventClick String
    | EventMouseEnter String
    | EventMouseLeave String
