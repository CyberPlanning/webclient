module Secret exposing (..)

import Array exposing (Array)
import Html exposing (Html, iframe)
import Html.Attributes exposing (attribute, height, src, width, class, style)
import Dict exposing (Dict)


type alias StateList =
    List State


type alias State =
    { code : Array Int
    , index : Int
    , yt : String
    , opts : Dict String String
    , class : String
    }


createStates : StateList
createStates =
    [ { code = Array.fromList [ 38, 38, 40, 40, 37, 39, 37, 39, 66, 65 ]
      , index = 0
      , yt = "-iYBIsLFbKo"
      , opts = Dict.fromList 
            [ ("start", "6")
            ]
      , class = "fun"
      }
    , { code = Array.fromList [ 65, 66, 39, 37, 39, 37, 40, 40, 38, 38 ]
      , index = 0
      , yt = "vN-ARytZKgQ"
      , opts = Dict.empty
      , class = "fun2"
      }
    , { code = Array.fromList [ 83, 65, 77, 66, 65 ]
      , index = 0
      , yt = "HAiHEQblKeQ"
      , opts = Dict.fromList 
            [ ("start", "24")
            ]
      , class = "fun3"
      }
    ]


update : Int -> StateList -> StateList
update key state =
    List.map (updateState key) state


updateState : Int -> State -> State
updateState code state =
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



classStyle : StateList -> List (Html.Attribute msg)
classStyle state =
    List.filter activated state
    |> List.map (.class >> class)


view : StateList -> Html msg
view state =
    List.filter activated state
    |> List.map viewState
    |> Html.div [ style "height" "0" ]


viewState : State -> Html msg
viewState state =
    let
        extraOpts =
            Dict.foldl (\k v s -> (k ++ "=" ++ v) :: s ) [] state.opts
            |> String.join "&"

        id = state.yt
    in
        iframe
            [ width 0
            , height 0
            , src ("https://www.youtube.com/embed/" ++ id ++ "?rel=0&controls=0&showinfo=0&autoplay=1&" ++ extraOpts)
            , attribute "frameborder" "0"
            , attribute "allow" "autoplay; encrypted-media"
            , attribute "allowfullscreen" "1"
            ]
            []


activated : State -> Bool
activated state =
    Array.length state.code == state.index
