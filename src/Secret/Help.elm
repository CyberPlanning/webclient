module Secret.Help exposing (Help, helpEvents, helpMessages)

import Calendar.Event as Cal
import Cyberplanning.Utils exposing (computeStyle)
import MyTime
import Time exposing (Posix)
import Time.Extra as TimeExtra


type alias Help =
    { title : String
    , desc : String
    , desc2 : String
    , weekday : TimeExtra.Interval
    , startHour : Int
    , startMinute : Int
    , endHour : Int
    , endMinute : Int
    }


helpMessages : List Help
helpMessages =
    [ { title = "ChickenSong"
      , desc = "Taper le Konami code"
      , desc2 = ""
      , weekday = TimeExtra.Monday
      , startHour = 8
      , startMinute = 42
      , endHour = 13
      , endMinute = 55
      }
    , { title = "Help"
      , desc = "Affiche ce message"
      , desc2 = ""
      , weekday = TimeExtra.Tuesday
      , startHour = 12
      , startMinute = 30
      , endHour = 16
      , endMinute = 0
      }
    , { title = "Soviet National Anthem 31 "
      , desc = "reverse(KonamiCode)"
      , desc2 = ""
      , weekday = TimeExtra.Wednesday
      , startHour = 8
      , startMinute = 0
      , endHour = 11
      , endMinute = 15
      }
    , { title = "Samba 🎉"
      , desc = "Type S A M B A"
      , desc2 = ""
      , weekday = TimeExtra.Thursday
      , startHour = 17
      , startMinute = 0
      , endHour = 19
      , endMinute = 0
      }
    ]


helpToEvent : Posix -> Help -> Cal.Event
helpToEvent viewing help =
    let
        eventDay =
            MyTime.floor TimeExtra.Monday viewing
                |> MyTime.ceiling help.weekday

        start =
            MyTime.add TimeExtra.Hour help.startHour eventDay
                |> MyTime.add TimeExtra.Minute help.startMinute

        end =
            MyTime.add TimeExtra.Hour help.endHour eventDay
                |> MyTime.add TimeExtra.Minute help.endMinute
    in
    { toId = help.title
    , title = help.title
    , startTime = start
    , endTime = end
    , description = [ help.desc, help.desc2 ]
    , style = computeStyle help.title
    , source = ""
    , position = Cal.All
    }


helpEvents : Posix -> List Cal.Event
helpEvents viewing =
    List.map (helpToEvent viewing) helpMessages
