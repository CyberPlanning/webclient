module Calendar.Internal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (..)
import Date exposing (Date)
import Date.Extra
import Calendar.Config exposing (ViewConfig, EventConfig, TimeSlotConfig)
import Calendar.Day as Day
import Calendar.Week as Week
import Calendar.Msg exposing (Msg(..), TimeSpan(..))


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


view : ViewConfig event -> List event -> State -> Html Msg
view config events { viewing, timeSpan, selected } =
    let
        calendarView =
            case timeSpan of
                Week ->
                    Week.view config events selected viewing

                Day ->
                    Day.view config events selected viewing
    in
        div
            [ class "elm-calendar--container"
            , Html.Attributes.draggable "false"
            ]
            [ div [ class "elm-calendar--calendar" ]
                [ calendarView ]
            ]