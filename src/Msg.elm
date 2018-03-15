module Msg exposing (..)

import Types exposing (Query)
import Date
import Http exposing (Error)
import Window
import Calendar.Msg as Calendar
import Swipe

type Msg
    = Noop
    | GraphQlMsg (Result Error Query)
    | SetDate Date.Date
    | SetGroup String
    | WindowSize Window.Size
    | PageBack
    | PageForward
    | KeyDown Int
    | SetCalendarState Calendar.Msg
    | SwipeEvent Swipe.Msg
    | ClickToday
    | LoadGroup String
    | SavedGroup String
    | StopReloadIcon ()