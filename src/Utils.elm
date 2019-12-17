module Utils exposing (initialModel)

import Calendar.Calendar as Calendar
import Calendar.Msg
import Cyberplanning.Cyberplanning as Cyberplanning
import Model exposing (Model)
import Personnel.Personnel as Personnel
import Secret.Secret as Secret
import Storage
import Time
import Vendor.Swipe


initialModel : Storage.Storage -> Model
initialModel { cyberplanning, personnel } =
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
