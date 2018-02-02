module Calendar.Helpers exposing (..)

import Date exposing (Date)
import Date.Extra
import List.Extra
import Color exposing (Color)
import Hex


hourString : Date -> String
hourString =
    Date.Extra.toFormattedString "H:mm"


dateString : Date -> String
dateString =
    Date.Extra.toFormattedString "EEEE dd"


bumpMidnightBoundary : Date -> Date
bumpMidnightBoundary date =
    if Date.Extra.fractionalDay date == 0 then
        Date.Extra.add Date.Extra.Millisecond 1 date
    else
        date


hours : Date -> List Date
hours date =
    let
        day =
            bumpMidnightBoundary date

        midnight =
            Date.Extra.floor Date.Extra.Day day |> Date.Extra.add Date.Extra.Hour 7

        lastHour =
            Date.Extra.ceiling Date.Extra.Day day |> Date.Extra.add Date.Extra.Hour -4
    in
        Date.Extra.range Date.Extra.Hour 1 midnight lastHour


weekRangesFromMonth : Int -> Date.Month -> List (List Date)
weekRangesFromMonth year month =
    let
        firstOfMonth =
            Date.Extra.fromCalendarDate year month 1

        firstOfNextMonth =
            Date.Extra.add Date.Extra.Month 1 firstOfMonth
    in
        Date.Extra.range Date.Extra.Day
            1
            (Date.Extra.floor Date.Extra.Sunday firstOfMonth)
            (Date.Extra.ceiling Date.Extra.Sunday firstOfNextMonth)
            |> List.Extra.groupsOf 7


dayRangeOfWeek : Date -> List Date
dayRangeOfWeek date =
    let
        weekDate = date
                 |> Date.Extra.add Date.Extra.Day 2
                 |> Date.Extra.floor Date.Extra.Monday
    in
        Date.Extra.range Date.Extra.Day
            1
            (Date.Extra.floor Date.Extra.Monday weekDate)
            (Date.Extra.ceiling Date.Extra.Saturday weekDate)



colorToHex : Color -> String
colorToHex color =
    let
        rgb =
            Color.toRgb color

        toHex =
            Hex.toString >> String.padLeft 2 '0'
    in
        "#" ++ (toHex rgb.red) ++ (toHex rgb.green) ++ (toHex rgb.blue)


noBright : Color -> Color
noBright color =
    let
        hsl = 
            Color.toHsl color

        newLightness =
            if hsl.lightness > 0.5 then
                0.5
            else
                hsl.lightness
    in
        Color.hsl hsl.hue hsl.saturation newLightness
