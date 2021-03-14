port module Storage exposing (Storage, saveState)


type alias Storage =
    { graphqlUrl : String
    , cyberplanning : String
    , personnel : String
    }


port saveState : ( String, String ) -> Cmd msg
