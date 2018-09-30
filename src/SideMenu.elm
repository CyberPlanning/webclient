module SideMenu exposing (view)

import Calendar.Msg exposing (TimeSpan)
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Model exposing (Group)
import Msg exposing (Msg)


view : Bool -> Group -> TimeSpan -> Html Msg
view opened group timespan =
    div [ class "sidemenu--main" ] []
