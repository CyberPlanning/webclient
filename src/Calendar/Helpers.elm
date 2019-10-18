module Calendar.Helpers exposing (colorToHex, computeColor, dateString, dayRangeOfAllWeek, dayRangeOfWeek, hours, noBright)

import Hex
import MD5
import MyTime
import Time exposing (Posix, Weekday(..))
import Time.Extra as TimeExtra
import Vendor.Color exposing (Color)


dateString : Posix -> String
dateString date =
    let
        weekday =
            MyTime.toWeekday date

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
            MyTime.toDay date
                |> String.fromInt
    in
    weekname ++ " " ++ day


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
    , "20:00"
    ]


dayRangeOfWeek : Posix -> List Posix
dayRangeOfWeek date =
    let
        weekDate =
            date
                -- move to middle week because week-end are not showned
                |> MyTime.add TimeExtra.Day 2
                |> MyTime.floor TimeExtra.Monday
    in
    MyTime.range TimeExtra.Day
        1
        weekDate
        (MyTime.ceiling TimeExtra.Saturday weekDate)


dayRangeOfAllWeek : Posix -> List Posix
dayRangeOfAllWeek date =
    let
        weekDate =
            date
                -- Fix : range return no value if it is Monday midnight
                |> MyTime.floor TimeExtra.Day
                |> MyTime.add TimeExtra.Millisecond 1
    in
    MyTime.range TimeExtra.Day
        1
        (MyTime.floor TimeExtra.Monday weekDate)
        (MyTime.ceiling TimeExtra.Monday weekDate)


computeColor : String -> String
computeColor text =
    let
        hex =
            String.dropRight 1 text
                |> String.toUpper
                |> MD5.hex
                |> String.right 6

        red =
            String.slice 0 2 hex
                |> Hex.fromString
                |> Result.withDefault 0

        green =
            String.slice 2 4 hex
                |> Hex.fromString
                |> Result.withDefault 0

        blue =
            String.slice 4 6 hex
                |> Hex.fromString
                |> Result.withDefault 0
    in
    Vendor.Color.rgb red green blue
        |> noBright
        |> colorToHex


colorToHex : Color -> String
colorToHex color =
    let
        rgb =
            Vendor.Color.toRgb color

        toHex =
            Hex.toString >> String.padLeft 2 '0'
    in
    "#" ++ toHex rgb.red ++ toHex rgb.green ++ toHex rgb.blue


noBright : Color -> Color
noBright color =
    let
        hsl =
            Vendor.Color.toHsl color

        -- hsl.lightness * 0.7
        newLightness =
            if hsl.lightness > 0.4 then
                0.4

            else
                hsl.lightness

        newSaturation =
            hsl.saturation * 0.85
    in
    Vendor.Color.hsl hsl.hue hsl.saturation newLightness
