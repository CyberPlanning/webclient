port module Storage exposing (doload, load, save, saved)


port save : String -> Cmd msg


port saved : (String -> msg) -> Sub msg


port doload : () -> Cmd msg


port load : (String -> msg) -> Sub msg
