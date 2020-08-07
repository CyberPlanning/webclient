module Utils exposing (initialModel, generateFragment)

import Browser.Navigation as Nav
import Calendar.Calendar as Calendar
import Calendar.Msg
import Cyberplanning.Cyberplanning as Cyberplanning
import Cyberplanning.Types exposing (Group)
import Model exposing (Model)
import Personnel.Personnel as Personnel
import Secret.Secret as Secret
import Storage
import Time
import Vendor.Swipe
import Url
import Config
import Bitwise


initialModel : Storage.Storage -> Url.Url -> Nav.Key -> Model
initialModel { cyberplanning, personnel } url navKey =
    { navKey = navKey
    , url = url
    , date = Nothing
    , calendarState = Calendar.init Calendar.Msg.Week (Time.millisToPosix 0)
    , size = { width = 1200, height = 800 }
    , swipe = Vendor.Swipe.init
    , loop = False
    , secret = Secret.createStates
    , tooltipHover = False
    , menuOpened = False
    , personnelState = Personnel.restoreState personnel
    , planningState = Cyberplanning.restoreState cyberplanning |> urlForceGroup url
    }


parseFragment : String -> Maybe (List Int)
parseFragment code =
    code
    |> String.split ","
    |> List.map String.toInt
    |> List.foldl fx (Just [])


fx : Maybe a -> Maybe (List a) -> Maybe (List a)
fx entry store =
    Maybe.andThen (fxx entry) store

fxx : Maybe a -> List a -> Maybe (List a)
fxx entry list =
    Maybe.andThen (\id -> Just (id :: list)) entry


findGroup : List Group -> Int -> Maybe Group
findGroup list id =
    case list of
        [] ->
            Nothing

        first :: rest ->
            if first.id == id then
                Just first

            else
                findGroup rest id


findGroups : List Int -> Maybe (List Group)
findGroups list =
    list
    |> List.map (findGroup Config.allGroups)
    |> List.foldl fx (Just [])


urlForceGroup : Url.Url -> Cyberplanning.State -> Cyberplanning.State
urlForceGroup url state =
    url.fragment
    |> Maybe.andThen Url.percentDecode
    -- |> Maybe.map (Debug.log "Before" >> xorString >> Debug.log "After")
    |> Maybe.andThen parseFragment
    |> Maybe.andThen findGroups
    |> Maybe.map (\gs -> {state | selectedGroups = gs})
    |> Maybe.withDefault state


generateFragment : List Group -> String
generateFragment groups =
    groups
    |> List.map .id
    |> List.map String.fromInt
    |> String.join ","
    -- |> xorString


-- Xor encode

xorKey : List Char
xorKey =
    "https://cyberplanning.fr/flags/thereisaflaginsourcecode"
    |> String.toList


xorChar : (Char, Char) -> Char
xorChar (c, k) =
    let
        cCode = Char.toCode c
        kCode = Char.toCode k
    in
        Bitwise.xor cCode kCode
        |> modBy 256
        |> Char.fromCode


xorString : String -> String
xorString str =
    String.toList str
    |> List.map2 Tuple.pair xorKey
    |> List.map xorChar
    |> List.map String.fromChar
    |> String.join ""

