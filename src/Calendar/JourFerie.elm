module Calendar.JourFerie exposing (..)

import Dict
import Date exposing (Date, Month(..))
import Date.Extra as Dateextra exposing (Interval(..))


jourFerie: Dict.Dict String Date -> Date -> Maybe String
jourFerie joursFeries day =
    let
        dd = Dateextra.floor Day day
    in
        Dict.filter (\k v -> Dateextra.equal v dd) joursFeries
        |> Dict.keys
        |> List.head


jourFerieName: Dict.Dict String Date -> String -> Maybe Date
jourFerieName joursFeries name =
        Dict.get name joursFeries


getAllJourFerie: Int -> Dict.Dict String Date
getAllJourFerie year =
    let
        -- Paques
        n = year % 19
        c = year // 100
        u = year % 100
        s = c // 4
        t = c % 4
        p = (c + 8) // 25
        q = (c - p + 1) // 3
        e = (19 * n + c - s - q + 15) % 30
        b = u // 4
        d = u % 4
        l = (2 * t + 2 * b - e - d + 32) % 7
        h = (n + 11 * e + 22 * l) // 451
        n0 = (e + l - 7 * h + 114)
        m = n0 // 31
        j = n0 % 31
        paques = Dateextra.fromCalendarDate year (Dateextra.numberToMonth m) (j + 1)

        lundiPaques = Dateextra.add Day 1 paques
        ascension = Dateextra.add Day 39 paques
        pentecote = Dateextra.add Day 50 paques

        jourDeLAn      = Dateextra.fromCalendarDate year Jan 1
        feteDuTravail  = Dateextra.fromCalendarDate year May 1
        victoireAllies = Dateextra.fromCalendarDate year May 8
        feteNationale  = Dateextra.fromCalendarDate year Jul 14
        assomption     = Dateextra.fromCalendarDate year Aug 15
        toussaint      = Dateextra.fromCalendarDate year Nov 1
        armistice      = Dateextra.fromCalendarDate year Nov 11
        noel           = Dateextra.fromCalendarDate year Dec 25


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