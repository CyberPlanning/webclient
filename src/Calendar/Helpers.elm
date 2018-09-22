module Calendar.Helpers exposing (colorToHex, dateString, dayRangeOfWeek, hours, noBright, weekRangesFromMonth)

import Color exposing (Color)
import Date exposing (Date)
import Hex
import List.Extra
import Time exposing (Weekday(..))


dateString : Date -> String
dateString date =
    let
        weekday =
            Date.weekday date

        weekname =
            case weekday of
                Mon ->
                    "Lundi"

                Tue ->
                    "Mardi"

                Wed ->
                    "Mercredi"

                Thu ->
                    "Jeudi"

                Fri ->
                    "Vendredi"

                Sat ->
                    "Samedi"

                Sun ->
                    "Dimanche"

        day =
            Date.day date
                |> String.fromInt
    in
    weekname ++ " " ++ day



-- TODO
-- bumpMidnightBoundary : Date -> Date
-- bumpMidnightBoundary date =
--     if Date.fractionalDay date == 0 then
--         Date.add Date.Millisecond 1 date
--     else
--         date


hours : List String
hours =
    [ "7:00"
    , "8:00"
    , "9:00"
    , "10:00"
    , "11:00"
    , "12:00"
    , "13:00"
    , "14:00"
    , "15:00"
    , "16:00"
    , "17:00"
    , "18:00"
    , "19:00"
    ]


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
                -- move to middle week because week-end are not showned
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

        -- hsl.lightness * 0.7
        newLightness =
            if hsl.lightness > 0.4 then
                0.4

            else
                hsl.lightness

        newSaturation =
            hsl.saturation * 0.85
    in
    Color.hsl hsl.hue hsl.saturation newLightness
