module Secret exposing (..)

import Array exposing(Array)

import Html exposing(Html, iframe)
import Html.Attributes exposing(width, height, src, attribute)

type alias State =
    { code : Array Int
    , index : Int
    }


createState: State
createState =
    { code = Array.fromList [38, 38, 40, 40, 37, 39, 37, 39, 66, 65]
    , index = 0
    }


update: Int -> State -> State
update code state =
    let
        currentCode =
            Array.get state.index state.code
    in
        case currentCode of
            Just expected ->
                if code == expected then
                    {state | index = state.index + 1}
                else
                    {state | index = 0}

            Nothing ->
                {state | index = 0}

view: Html msg
view =
    iframe [ width 0
           , height 0
           , src "https://www.youtube.com/embed/-iYBIsLFbKo?rel=0&amp;controls=0&amp;showinfo=0&amp;autoplay=1&amp;start=6"
           , attribute "frameborder" "0"
           , attribute "allow" "autoplay; encrypted-media"
           , attribute "allowfullscreen" "1"
           ]
           []


activated: State -> Bool
activated state =
    Array.length state.code == state.index

