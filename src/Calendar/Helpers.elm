module Calendar.Helpers exposing (colorToHex, dateString, dayRangeOfWeek, hours, noBright, weekRangesFromMonth)

import Color exposing (Color)
import Hex
import List.Extra
import Time exposing (Posix, Weekday(..))
import Time.Extra as TimeExtra exposing (Parts)
import TimeZone exposing (europe__paris)


paris : Time.Zone
paris =
    europe__paris


dateString : Posix -> String
dateString date =
    let
        weekday =
            Time.toWeekday paris date

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
            Time.toDay paris date
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


weekRangesFromMonth : Int -> Time.Month -> List (List Posix)
weekRangesFromMonth year month =
    let
        firstOfMonth =
            TimeExtra.partsToPosix paris (Parts year month 1 0 0 0 0)

        firstOfNextMonth =
            TimeExtra.add TimeExtra.Month 1 paris firstOfMonth
    in
    TimeExtra.range TimeExtra.Day
        1
        paris
        (TimeExtra.floor TimeExtra.Sunday paris firstOfMonth)
        (TimeExtra.ceiling TimeExtra.Sunday paris firstOfNextMonth)
        |> List.Extra.groupsOf 7


dayRangeOfWeek : Posix -> List Posix
dayRangeOfWeek date =
    let
        weekDate =
            date
                -- move to middle week because week-end are not showned
                |> TimeExtra.add TimeExtra.Day 2 paris
                |> TimeExtra.floor TimeExtra.Monday paris
    in
    TimeExtra.range TimeExtra.Day
        1
        paris
        (TimeExtra.floor TimeExtra.Monday paris weekDate)
        (TimeExtra.ceiling TimeExtra.Saturday paris weekDate)


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
