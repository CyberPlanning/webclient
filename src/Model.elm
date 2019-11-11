module Model exposing (Model, WindowSize)

import Calendar.Calendar as Calendar
import Cyberplanning.Cyberplanning as Cyberplanning
import Http exposing (Error)
import Personnel.Personnel as Personnel
import Secret.Secret
import Time exposing (Posix)
import Vendor.Swipe



---- MODEL ----


type alias WindowSize =
    { width : Int
    , height : Int
    }


type alias Model =
    { date : Maybe Posix
    , size : WindowSize
    , swipe : Vendor.Swipe.State
    , loop : Bool
    , secret : Secret.Secret.StateList
    , tooltipHover : Bool
    , menuOpened : Bool
    , calendarState : Calendar.State
    , planningState : Cyberplanning.State
    , personnelState : Personnel.State
    }
