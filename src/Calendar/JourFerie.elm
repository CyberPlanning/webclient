module Calendar.JourFerie exposing (getAllJourFerie, jourFerie, jourFerieName)

import Date exposing (Date, Interval(..), Unit(..))
import Dict
import Time exposing (Month(..))


jourFerie : Dict.Dict String Date -> Date -> Maybe String
jourFerie joursFeries day =
    let
        dd =
            Date.floor Day day
    in
    Dict.filter (\k v -> v == dd) joursFeries
        |> Dict.keys
        |> List.head


jourFerieName : Dict.Dict String Date -> String -> Maybe Date
jourFerieName joursFeries name =
    Dict.get name joursFeries


getAllJourFerie : Int -> Dict.Dict String Date
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
            Date.fromCalendarDate year (Date.numberToMonth m) (j + 1)

        lundiPaques =
            Date.add Days 1 paques

        ascension =
            Date.add Days 39 paques

        pentecote =
            Date.add Days 50 paques

        jourDeLAn =
            Date.fromCalendarDate year Jan 1

        feteDuTravail =
            Date.fromCalendarDate year May 1

        victoireAllies =
            Date.fromCalendarDate year May 8

        feteNationale =
            Date.fromCalendarDate year Jul 14

        assomption =
            Date.fromCalendarDate year Aug 15

        toussaint =
            Date.fromCalendarDate year Nov 1

        armistice =
            Date.fromCalendarDate year Nov 11

        noel =
            Date.fromCalendarDate year Dec 25
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
