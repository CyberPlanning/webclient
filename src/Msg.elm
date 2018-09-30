module Msg exposing (Msg(..))

import Browser.Dom exposing (Viewport)
import Calendar.Msg as Calendar
import Http exposing (Error)
import Swipe
import Time exposing (Posix)
import Types exposing (Query)


type Msg
    = Noop
    | GraphQlMsg (Result Error Query)
    | SetDate Posix
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
    | ToggleMenu
    | StopReloadIcon ()
