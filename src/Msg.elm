module Msg exposing (Msg(..))

import Browser.Dom exposing (Viewport)
import Calendar.Msg as Calendar
import Date
import Http exposing (Error)
import Swipe
import Types exposing (Query)


type Msg
    = Noop
    | GraphQlMsg (Result Error Query)
    | SetDate Date.Date
    | SetGroup String
    | WindowSize Viewport
    | PageBack
    | PageForward
    | KeyDown Int
    | SetCalendarState Calendar.Msg
    | SwipeEvent Swipe.Msg
    | ClickToday
    | LoadGroup String
    | SavedGroup String
    | StopReloadIcon ()
