module Calendar.Msg exposing (..)

type TimeSpan
    = Week
    | Day


type Msg
    = PageBack
    | PageForward
    | ChangeTimeSpan TimeSpan
    | EventClick String
    | EventMouseEnter String
    | EventMouseLeave String
