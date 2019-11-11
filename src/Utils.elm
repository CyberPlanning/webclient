module Utils exposing (initialModel)

import Calendar.Calendar as Calendar
import Calendar.Msg
import Config exposing (allGroups, firstGroup)
import Cyberplanning.Cyberplanning as Cyberplanning
import Iso8601
import Model exposing (Model)
import Personnel.Personnel as Personnel
import Secret.Secret as Secret
import Set
import Storage
import Time exposing (Posix)
import Vendor.Swipe


initialModel : Storage.Storage -> Model
initialModel { graphqlUrl, cyberplanning, personnel } =
    { date = Nothing
    , calendarState = Calendar.init Calendar.Msg.Week (Time.millisToPosix 0)
    , size = { width = 1200, height = 800 }
    , swipe = Vendor.Swipe.init
    , loop = False
    , secret = Secret.createStates
    , tooltipHover = False
    , menuOpened = False
    , personnelState = Personnel.restoreState personnel
    , planningState = Cyberplanning.restoreState cyberplanning
    }
