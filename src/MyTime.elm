module MyTime exposing (add, ceiling, diff, floor, partsToPosix, range, toDay, toHour, toMinute, toMonth, toOffset, toSecond, toWeekday, toYear, weekdayToNumber)

import Time exposing (Posix, Weekday(..))
import Time.Extra as TimeExtra exposing (Interval)
import Vendor.TimeZone exposing (europe__paris)


toYear : Posix -> Int
toYear =
    Time.toYear europe__paris


add : Interval -> Int -> Posix -> Posix
add interval value =
    TimeExtra.add interval value europe__paris


ceiling : Interval -> Posix -> Posix
ceiling interval =
    TimeExtra.ceiling interval europe__paris


floor : Interval -> Posix -> Posix
floor interval =
    TimeExtra.floor interval europe__paris


diff : Interval -> Posix -> Posix -> Int
diff interval =
    TimeExtra.diff interval europe__paris


range : Interval -> Int -> Posix -> Posix -> List Posix
range interval value =
    TimeExtra.range interval value europe__paris


toOffset : Posix -> Float
toOffset =
    TimeExtra.toOffset europe__paris >> toFloat


toSecond : Posix -> Int
toSecond =
    Time.toSecond europe__paris


toMinute : Posix -> Int
toMinute =
    Time.toMinute europe__paris


toHour : Posix -> Int
toHour =
    Time.toHour europe__paris


toDay : Posix -> Int
toDay =
    Time.toDay europe__paris


toWeekday : Posix -> Time.Weekday
toWeekday =
    Time.toWeekday europe__paris


toMonth : Posix -> Time.Month
toMonth =
    Time.toMonth europe__paris


partsToPosix : TimeExtra.Parts -> Posix
partsToPosix =
    TimeExtra.partsToPosix europe__paris


weekdayToNumber : Time.Weekday -> Int
weekdayToNumber wd =
    case wd of
        Mon ->
            1

        Tue ->
            2

        Wed ->
            3

        Thu ->
            4

        Fri ->
            5

        Sat ->
            6

        Sun ->
            7
