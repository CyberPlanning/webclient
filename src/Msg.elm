module Msg exposing (Msg(..))

import Browser.Dom exposing (Viewport)
import Calendar.Msg as Calendar
import Cyberplanning.Cyberplanning as Cyberplanning
import Personnel.Personnel as Personnel
import Time exposing (Posix)
import Vendor.Swipe



{- Events types

   - Init:
       SetDate
       WindowSize

   - TopBar:
       ClickToday
       Reload
       ToggleMenu

   - SideMenu:
       ChangeMode

   - Internal:
       SetCalendarState
       SetPersonnelState
       SetPlanningState

   - Subscription:
       KeyDown
       SwipeEvent
       StopReloadIcon

-}


type Msg
    = Noop
    | SetDate Posix
    | WindowSize Viewport
    | KeyDown Int
    | SetCalendarState Calendar.Msg
    | SetPersonnelState Personnel.Msg
    | SetPlanningState Cyberplanning.Msg
    | SwipeEvent Vendor.Swipe.Msg
    | ClickToday
    | ToggleMenu
    | StopReloadIcon ()
    | ChangeMode Calendar.TimeSpan
    | Reload
