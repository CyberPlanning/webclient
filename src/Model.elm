module Model exposing (Model, WindowSize)

import Browser.Navigation as Nav
import Calendar.Calendar as Calendar
import Cyberplanning.Cyberplanning as Cyberplanning
import Personnel.Personnel as Personnel
import Secret.Secret
import Time exposing (Posix)
import Vendor.Swipe
import Url


---- MODEL ----


type alias WindowSize =
    { width : Int
    , height : Int
    }


type alias Model =
    { navKey : Nav.Key
    , url : Url.Url
    , date : Maybe Posix
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
