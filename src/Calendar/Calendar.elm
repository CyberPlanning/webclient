module Calendar.Calendar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (on, keyCode)
import Date exposing (Date)
import Date.Extra
import Calendar.Day as Day
import Calendar.Week as Week
import Calendar.Msg exposing (Msg(..), TimeSpan(..))
import Calendar.Event exposing (Event)
import Json.Decode as Json


type alias State =
    { timeSpan : TimeSpan
    , viewing : Date
    , hover : Maybe String
    , selected : Maybe String
    }


init : TimeSpan -> Date -> State
init timeSpan viewing =
    { timeSpan = timeSpan
    , viewing = viewing
    , hover = Nothing
    , selected = Nothing
    }


update : Msg -> State -> State
update msg state =
    -- case Debug.log "msg" msg of
    case msg of
        PageBack ->
            page -1 state 

        PageForward ->
            page 1 state

        ChangeTimeSpan timeSpan ->
            changeTimeSpan timeSpan state

        EventClick eventId ->
            { state | selected = Just eventId }

        EventMouseEnter eventId ->
            { state | hover = Just eventId }

        EventMouseLeave eventId ->
            { state | hover = Nothing }


page : Int -> State -> State
page step state =
    let
        { timeSpan, viewing } =
            state
    in
        case timeSpan of
            Week ->
                { state | viewing = Date.Extra.add Date.Extra.Week step viewing }

            Day ->
                { state | viewing = Date.Extra.add Date.Extra.Day step viewing }


changeTimeSpan : TimeSpan -> State -> State
changeTimeSpan timeSpan state =
    { state | timeSpan = timeSpan }


view : List Event -> State -> Html Msg
view events { viewing, timeSpan, selected } =
    let
        calendarView =
            case timeSpan of
                Week ->
                    Week.view events selected viewing

                Day ->
                    Day.view events selected viewing
    in
        div
            [ class "calendar--calendar" ]
            [ calendarView ]


onKeyDown : msg -> Attribute msg
onKeyDown msg =
    let
        isEnter code =
            if code == 13 then
                Json.succeed msg
            else
                Json.fail "not ENTER"
    in
        on "keydown" (Json.andThen isEnter keyCode)
