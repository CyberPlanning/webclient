module Calendar.Calendar exposing (State, init, page, update, view)

import Calendar.Day as Day
import Calendar.Event exposing (Event)
import Calendar.JourFerie exposing (getAllJourFerie)
import Calendar.Msg exposing (Msg(..), TimeSpan(..))
import Calendar.Week as Week
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (keyCode, on)
import Json.Decode as Json
import Time exposing (Posix)
import Time.Extra as TimeExtra
import TimeZone exposing (europe__paris)


type alias State =
    { timeSpan : TimeSpan
    , viewing : Posix
    , hover : Maybe String
    , selected : Maybe String
    , joursFeries : Dict String Posix
    }


init : TimeSpan -> Posix -> State
init timeSpan viewing =
    { timeSpan = timeSpan
    , viewing = viewing
    , hover = Nothing
    , selected = Nothing
    , joursFeries = getAllJourFerie (Time.toYear europe__paris viewing)
    }


update : Msg -> State -> State
update msg state =
    -- case Debug.log "msg" msg of
    case msg of
        PageBack ->
            page -1 state

        PageForward ->
            page 1 state

        WeekBack ->
            page -7 state

        WeekForward ->
            page 7 state

        ChangeTimeSpan timeSpan ->
            { state | timeSpan = timeSpan }

        ChangeViewing viewing ->
            { state | viewing = viewing }

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

        interval =
            case timeSpan of
                Week ->
                    TimeExtra.Week

                AllWeek ->
                    TimeExtra.Week

                Day ->
                    TimeExtra.Day
    in
    { state | viewing = TimeExtra.add interval step europe__paris viewing, hover = Nothing }


view : List Event -> State -> Html Msg
view events { viewing, timeSpan, selected, joursFeries } =
    let
        calendarView =
            case timeSpan of
                Week ->
                    Week.view events selected viewing joursFeries

                AllWeek ->
                    Week.viewAll events selected viewing joursFeries

                Day ->
                    Day.view events selected viewing joursFeries
    in
    div
        [ class "calendar--calendar" ]
        [ calendarView ]
