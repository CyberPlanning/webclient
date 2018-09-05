module Secret exposing (State, activated, createState1, createState2, update, view)

import Array exposing (Array)
import Html exposing (Html, iframe)
import Html.Attributes exposing (attribute, height, src, width)


type alias State =
    { code : Array Int
    , index : Int
    , yt : String
    }


createState1 : State
createState1 =
    { code = Array.fromList [ 38, 38, 40, 40, 37, 39, 37, 39, 66, 65 ]
    , index = 0
    , yt = "-iYBIsLFbKo"
    }


createState2 : State
createState2 =
    { code = Array.fromList [ 65, 66, 39, 37, 39, 37, 40, 40, 38, 38 ]
    , index = 0
    , yt = "vN-ARytZKgQ"
    }


update : Int -> State -> State
update code state =
    let
        currentCode =
            Array.get state.index state.code
    in
    case currentCode of
        Just expected ->
            if code == expected then
                { state | index = state.index + 1 }

            else
                { state | index = 0 }

        Nothing ->
            { state | index = 0 }


view : String -> Html msg
view code =
    iframe
        [ width 0
        , height 0
        , src ("https://www.youtube.com/embed/" ++ code ++ "?rel=0&amp;controls=0&amp;showinfo=0&amp;autoplay=1&amp;start=6")
        , attribute "frameborder" "0"
        , attribute "allow" "autoplay; encrypted-media"
        , attribute "allowfullscreen" "1"
        ]
        []


activated : State -> Bool
activated state =
    Array.length state.code == state.index
