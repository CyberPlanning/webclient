module Msg exposing (..)

import Types exposing (Query)
import Date
import Http exposing (Error)
import Window
import Calendar.Msg

type Msg
    = GraphQlMsg (Result Error Query)
    | SetDate Date.Date
    | SetGroup String
    | SetCalendarState Calendar.Msg.Msg
    | WindowSize Window.Size
    | PageBack
    | PageForward
    | KeyDown Int