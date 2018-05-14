module Secret exposing (..)

import Array exposing(Array)


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


activated: State -> Bool
activated state =
    Array.length state.code == state.index

