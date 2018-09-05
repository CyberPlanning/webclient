module Calendar.Calendar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Date exposing (Date)
import Dict exposing (Dict)
import Date.Extra
import Calendar.Day as Day
import Calendar.Week as Week
import Calendar.Msg exposing (Msg(..), TimeSpan(..))
import Calendar.Event exposing (Event)
import Calendar.JourFerie exposing (getAllJourFerie)


type alias State =
    { timeSpan : TimeSpan
    , viewing : Date
    , hover : Maybe String
    , selected : Maybe String
    , joursFeries : Dict String Date
    }


init : TimeSpan -> Date -> State
init timeSpan viewing =
    { timeSpan = timeSpan
    , viewing = viewing
    , hover = Nothing
    , selected = Nothing
    , joursFeries = getAllJourFerie (Date.year viewing)
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
    in
        case timeSpan of
            Week ->
                { state | viewing = Date.Extra.add Date.Extra.Week step viewing, hover = Nothing }

            Day ->
                { state | viewing = Date.Extra.add Date.Extra.Day step viewing, hover = Nothing }


view : List Event -> State -> Html Msg
view events { viewing, timeSpan, selected, joursFeries } =
    let
        calendarView =
            case timeSpan of
                Week ->
                    Week.view events selected viewing joursFeries

                Day ->
                    Day.view events selected viewing joursFeries
    in
        div
            [ class "calendar--calendar" ]
            [ calendarView ]
