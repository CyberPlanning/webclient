module Secret exposing (StateList, classStyle, createStates, isHelpActivated, update, view)

import Array exposing (Array)
import Calendar.Event as Cal
import Dict exposing (Dict)
import Html exposing (Html, iframe)
import Html.Attributes exposing (attribute, class, height, src, style, width)


type alias StateList =
    { secrets : List YTState
    , help : State
    }


type alias YTState =
    { code : Array Int
    , index : Int
    , yt : String
    , opts : Dict String String
    , class : String
    }


type alias State =
    { code : Array Int
    , index : Int
    }


createStates : StateList
createStates =
    { secrets =
        [ { code = Array.fromList [ 38, 38, 40, 40, 37, 39, 37, 39, 66, 65 ]
          , index = 0
          , yt = "-iYBIsLFbKo"
          , opts =
                Dict.fromList
                    [ ( "start", "6" )
                    ]
          , class = "fun"
          }
        , { code = Array.fromList [ 65, 66, 39, 37, 39, 37, 40, 40, 38, 38 ]
          , index = 0
          , yt = "Rm6q_3WGy9M"
          , opts = Dict.empty
          , class = "fun2"
          }
        , { code = Array.fromList [ 83, 65, 77, 66, 65 ]
          , index = 0
          , yt = "HAiHEQblKeQ"
          , opts =
                Dict.fromList
                    [ ( "start", "24" )
                    ]
          , class = "fun3"
          }
        ]
    , help =
        { code = Array.fromList [ 72, 69, 76, 80 ]
        , index = 0
        }
    }


update : Int -> StateList -> StateList
update key state =
    let
        secrets =
            List.map (updateYTState key) state.secrets

        help =
            updateState key state.help
    in
    { secrets = secrets, help = help }


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


updateYTState : Int -> YTState -> YTState
updateYTState code state =
    let
        updated =
            updateState code { index = state.index, code = state.code }
    in
    { code = updated.code
    , index = updated.index
    , yt = state.yt
    , opts = state.opts
    , class = state.class
    }


classStyle : StateList -> List (Html.Attribute msg)
classStyle state =
    let
        helpStyle =
            if isHelpActivated state then
                [ class "fun-help" ]

            else
                []
    in
    List.filter activated state.secrets
        |> List.map (.class >> class)
        |> (++) helpStyle


view : StateList -> Html msg
view state =
    List.filter activated state.secrets
        |> List.map viewState
        |> Html.div [ style "height" "0" ]


viewState : YTState -> Html msg
viewState state =
    let
        extraOpts =
            Dict.foldl (\k v s -> (k ++ "=" ++ v) :: s) [] state.opts
                |> String.join "&"

        id =
            state.yt
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


activated : YTState -> Bool
activated state =
    Array.length state.code == state.index


toState : YTState -> State
toState state =
    { code = state.code
    , index = state.index
    }


isHelpActivated : StateList -> Bool
isHelpActivated { help } =
    Array.length help.code == help.index
