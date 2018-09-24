module Secret.Help exposing (Help, helpEvents, helpMessages)

import Calendar.Event as Cal
import Calendar.Helpers exposing (computeColor)
import Time exposing (Posix)
import Time.Extra as TimeExtra
import TimeZone exposing (europe__paris)


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
            TimeExtra.floor TimeExtra.Monday europe__paris viewing
                |> TimeExtra.ceiling help.weekday europe__paris

        start =
            TimeExtra.add TimeExtra.Hour help.startHour europe__paris eventDay
                |> TimeExtra.add TimeExtra.Minute help.startMinute europe__paris

        end =
            TimeExtra.add TimeExtra.Hour help.endHour europe__paris eventDay
                |> TimeExtra.add TimeExtra.Minute help.endMinute europe__paris
    in
    { toId = help.title
    , title = help.title
    , startTime = start
    , endTime = end
    , classrooms = [ help.desc ]
    , teachers = [ help.desc2 ]
    , groups = []
    , color = computeColor help.title
    }


helpEvents : Posix -> List Cal.Event
helpEvents viewing =
    List.map (helpToEvent viewing) helpMessages
