module Msg exposing (Msg(..))

import Browser.Dom exposing (Viewport)
import Calendar.Msg as Calendar
import Http exposing (Error)
import Model exposing (CustomEvent)
import Query.Types exposing (Query)
import Swipe
import Time exposing (Posix)


type Msg
    = Noop
    | GraphQlMsg (Result Error Query)
    | SetDate Posix
    | SetGroups (List String)
    | WindowSize Viewport
    | PageBack
    | PageForward
    | KeyDown Int
    | SetCalendarState Calendar.Msg
    | SwipeEvent Swipe.Msg
    | ClickToday
    | ToggleMenu
    | StopReloadIcon ()
    | ChangeMode Calendar.TimeSpan
    | CheckEvents CustomEvent Bool
    | Reload
