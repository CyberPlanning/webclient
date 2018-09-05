module Calendar.Helpers exposing (colorToHex, dateString, dayRangeOfWeek, hourString, hours, noBright, weekRangesFromMonth)

import Color exposing (Color)
import Date exposing (Date)
import Hex
import List.Extra


hourString : Date -> String
hourString =
    Date.format "H:mm"


dateString : Date -> String
dateString =
    Date.format "EEEE dd"



-- TODO
-- bumpMidnightBoundary : Date -> Date
-- bumpMidnightBoundary date =
--     if Date.fractionalDay date == 0 then
--         Date.add Date.Millisecond 1 date
--     else
--         date


hours : Date -> List Date
hours date =
    let
        -- bumpMidnightBoundary date
        day =
            date

        -- TODO
        -- |> Date.add Date.Hour 7
        morning =
            Date.floor Date.Day day

        -- TODO
        -- |> Date.add Date.Hour -4
        lastHour =
            Date.ceiling Date.Day day
    in
    Date.range Date.Day 1 morning lastHour


weekRangesFromMonth : Int -> Date.Month -> List (List Date)
weekRangesFromMonth year month =
    let
        firstOfMonth =
            Date.fromCalendarDate year month 1

        firstOfNextMonth =
            Date.add Date.Months 1 firstOfMonth
    in
    Date.range Date.Day
        1
        (Date.floor Date.Sunday firstOfMonth)
        (Date.ceiling Date.Sunday firstOfNextMonth)
        |> List.Extra.groupsOf 7


dayRangeOfWeek : Date -> List Date
dayRangeOfWeek date =
    let
        weekDate =
            date
                |> Date.add Date.Days 2
                |> Date.floor Date.Monday
    in
    Date.range Date.Day
        1
        (Date.floor Date.Monday weekDate)
        (Date.ceiling Date.Saturday weekDate)


colorToHex : Color -> String
colorToHex color =
    let
        rgb =
            Color.toRgb color

        toHex =
            Hex.toString >> String.padLeft 2 '0'
    in
    "#" ++ toHex rgb.red ++ toHex rgb.green ++ toHex rgb.blue


noBright : Color -> Color
noBright color =
    let
        hsl =
            Color.toHsl color

        newLightness =
            if hsl.lightness > 0.4 then
                0.4

            else
                hsl.lightness

        newSaturation =
            hsl.saturation * 0.85
    in
    -- TODO
    -- Color.hsl hsl.hue hsl.saturation newLightness
    -- Color.hsl (degrees 0) 0.7 0.7
    color
