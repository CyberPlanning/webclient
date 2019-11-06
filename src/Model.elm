module Model exposing (Collection(..), CustomEvent(..), FetchStatus(..), Group, Model, Settings, WindowSize)

import Calendar.Calendar as Calendar
import Calendar.Event as CalEvent
import Http exposing (Error)
import Secret.Secret
import Time exposing (Posix)
import Vendor.Swipe



---- MODEL ----


type alias WindowSize =
    { width : Int
    , height : Int
    }


type alias Model =
    { data : List CalEvent.Event --Maybe (Result String Query)
    , error : Maybe Error
    , date : Maybe Posix
    , selectedGroups : List Group
    , loading : Bool
    , size : WindowSize
    , calendarState : Calendar.State
    , swipe : Vendor.Swipe.State
    , loop : Bool
    , secret : Secret.Secret.StateList
    , settings : Settings
    , tooltipHover : Bool
    }


type alias Settings =
    { showHack2g2 : Bool
    , showCustom : Bool
    , menuOpened : Bool
    , allWeek : Bool
    }


type alias Group =
    { name : String
    , slug : String
    , collection : Collection
    , id : Int
    }


type Collection
    = Cyber
    | Info


type CustomEvent
    = Hack2g2
    | Custom


type FetchStatus
    = Loading
    | Error Error
    | None
