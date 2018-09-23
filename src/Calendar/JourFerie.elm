module Calendar.JourFerie exposing (getAllJourFerie, jourFerie, jourFerieName)

import Dict
import Time exposing (Month(..), Posix)
import Time.Extra as TimeExtra exposing (Parts)
import TimeZone exposing (europe__paris)


paris : Time.Zone
paris =
    europe__paris


jourFerie : Dict.Dict String Posix -> Posix -> Maybe String
jourFerie joursFeries day =
    let
        dd =
            TimeExtra.floor TimeExtra.Day paris day
    in
    Dict.filter (\k v -> v == dd) joursFeries
        |> Dict.keys
        |> List.head


jourFerieName : Dict.Dict String Posix -> String -> Maybe Posix
jourFerieName joursFeries name =
    Dict.get name joursFeries


getAllJourFerie : Int -> Dict.Dict String Posix
getAllJourFerie year =
    let
        -- Paques
        n =
            modBy 19 year

        c =
            year // 100

        u =
            modBy 100 year

        s =
            c // 4

        t =
            modBy 4 c

        p =
            (c + 8) // 25

        q =
            (c - p + 1) // 3

        e =
            modBy 30 (19 * n + c - s - q + 15)

        b =
            u // 4

        d =
            modBy 4 u

        l =
            modBy 7 (2 * t + 2 * b - e - d + 32)

        h =
            (n + 11 * e + 22 * l) // 451

        n0 =
            e + l - 7 * h + 114

        m =
            n0 // 31

        j =
            modBy 31 n0

        paques =
            TimeExtra.partsToPosix paris (Parts year (numberToMonth m) (j + 1) 0 0 0 0)

        lundiPaques =
            TimeExtra.add TimeExtra.Day 1 paris paques

        ascension =
            TimeExtra.add TimeExtra.Day 39 paris paques

        pentecote =
            TimeExtra.add TimeExtra.Day 50 paris paques

        jourDeLAn =
            TimeExtra.partsToPosix paris (Parts year Jan 1 0 0 0 0)

        feteDuTravail =
            TimeExtra.partsToPosix paris (Parts year May 1 0 0 0 0)

        victoireAllies =
            TimeExtra.partsToPosix paris (Parts year May 8 0 0 0 0)

        feteNationale =
            TimeExtra.partsToPosix paris (Parts year Jul 14 0 0 0 0)

        assomption =
            TimeExtra.partsToPosix paris (Parts year Aug 15 0 0 0 0)

        toussaint =
            TimeExtra.partsToPosix paris (Parts year Nov 1 0 0 0 0)

        armistice =
            TimeExtra.partsToPosix paris (Parts year Nov 11 0 0 0 0)

        noel =
            TimeExtra.partsToPosix paris (Parts year Dec 25 0 0 0 0)
    in
    [ ( "Pâques", paques )
    , ( "Lundi de Pâques", lundiPaques )
    , ( "Ascension", ascension )
    , ( "Pentecôte", pentecote )
    , ( "Jour de l'an", jourDeLAn )
    , ( "Fête du Travail", feteDuTravail )
    , ( "Victoire des allies", victoireAllies )
    , ( "Fête Nationale", feteNationale )
    , ( "Assomption", assomption )
    , ( "La Toussaint", toussaint )
    , ( "Armistice", armistice )
    , ( "Noël", noel )
    ]
        |> Dict.fromList


numberToMonth : Int -> Month
numberToMonth number =
    case max 1 number of
        1 ->
            Jan

        2 ->
            Feb

        3 ->
            Mar

        4 ->
            Apr

        5 ->
            May

        6 ->
            Jun

        7 ->
            Jul

        8 ->
            Aug

        9 ->
            Sep

        10 ->
            Oct

        11 ->
            Nov

        _ ->
            Dec
