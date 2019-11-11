module Cyberplanning.Types exposing (Collection(..), CustomEvent(..), Event, FetchStatus(..), Group, InternalMsg(..), InternalState, Planning, Query, RequestAction(..), Settings, defaultGroups, defaultSettings, defaultState)

import Calendar.Event as CalEvent
import Http exposing (Error)


type InternalMsg
    = Noop
    | SetGroups (List String)
    | CheckEvents CustomEvent Bool
    | GraphQlResult (Result Error Query)


type CustomEvent
    = Hack2g2
    | Custom


type alias InternalState =
    { events : List CalEvent.Event
    , selectedGroups : List Group
    , groupsCount : Int
    , status : FetchStatus
    , settings : Settings
    }


type alias Settings =
    { showHack2g2 : Bool
    , showCustom : Bool
    }


defaultState : InternalState
defaultState =
    { events = []
    , selectedGroups = defaultGroups
    , groupsCount = 0
    , status = Normal
    , settings = defaultSettings
    }


defaultSettings : Settings
defaultSettings =
    { showHack2g2 = True
    , showCustom = True
    }


defaultGroups : List Group
defaultGroups =
    []


type alias Planning =
    { events : List Event
    }


type alias Event =
    { title : String
    , startDate : String
    , endDate : String
    , classrooms : Maybe (List String)
    , teachers : Maybe (List String)
    , groups : Maybe (List String)
    , affiliations : Maybe (List String)
    , eventId : String
    }


type alias Query =
    { planning : Planning
    , hack2g2 : Maybe Planning
    , custom : Maybe Planning
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


type FetchStatus
    = Loading
    | Error Error
    | Normal


type RequestAction
    = RequestApi
    | SaveState
    | NoAction
