module Calendar.Calendar exposing (State, init, page, update, view)

import Calendar.Day as Day
import Calendar.Event exposing (Event)
import Calendar.JourFerie exposing (getAllJourFerie)
import Calendar.Msg exposing (InternalState, Msg(..), TimeSpan(..))
import Calendar.Week as Week
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (keyCode, on)
import Json.Decode as Json
import Time exposing (Posix)
import Time.Extra as TimeExtra
import TimeZone exposing (europe__paris)


type alias State =
    InternalState


init : TimeSpan -> Posix -> State
init timeSpan viewing =
    { timeSpan = timeSpan
    , viewing = viewing
    , hover = Nothing
    , position = Nothing
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

        EventClick eventId pos ->
            { state | selected = Just eventId, position = Just pos }

        EventMouseEnter eventId pos ->
            { state | hover = Just eventId, position = Just pos }

        EventMouseLeave eventId ->
            { state | hover = Nothing, selected = Nothing }


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
    { state | viewing = TimeExtra.add interval step europe__paris viewing, hover = Nothing, selected = Nothing }


view : List Event -> State -> Html Msg
view events state =
    let
        calendarView =
            case state.timeSpan of
                Week ->
                    Week.view state events

                AllWeek ->
                    Week.viewAll state events

                Day ->
                    Day.view state events
    in
    div
        [ class "calendar--calendar" ]
        [ calendarView ]
