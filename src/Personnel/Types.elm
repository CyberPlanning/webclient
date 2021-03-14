module Personnel.Types exposing (FileInfos, InternalState, defaultState)

import Calendar.Event as CalEvent
import Time exposing (Posix)


type alias FileInfos =
    { name : String
    , lastModified : Posix
    }


type alias InternalState =
    { events : List CalEvent.Event
    , file : Maybe FileInfos
    , active : Bool
    }


defaultState : InternalState
defaultState =
    { events = []
    , file = Nothing
    , active = False
    }
