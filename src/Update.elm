module Update exposing (..)

import Task
import Date
import Date.Extra as Dateextra

import Model exposing (Model, allGroups, toDatetime)
import Requests exposing (sendRequest, Msg(..))
import Calendar.Calendar as Calendar


---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetDate date ->
            let
                timespan = if model.size.width < 720 then
                                Calendar.Day
                           else
                                Calendar.Week
            in
                ( { model | date = Just date, calendarState = Calendar.init timespan date }
                , createPlanningRequest date model.selectedGroup.slug
                )

        GraphQlMsg response ->
            ( { model | data = Just response, loading = False }, Cmd.none )

        SetGroup slug ->
            let
                group =
                    Maybe.withDefault { slug = "12", name = "Cyber1 TD2" } <| find (\x -> x.slug == slug) allGroups

                cmd =
                    if model.loading then
                        Cmd.none
                    else
                        case model.date of
                            Just date ->
                                createPlanningRequest date slug

                            Nothing ->
                                Cmd.none
                
            in
                ( { model | selectedGroup = group, loading = True }, cmd )

        SetCalendarState calendarMsg ->
            let
                ( updatedCalendar, maybeMsg ) =
                    Calendar.update eventConfig timeSlotConfig calendarMsg model.calendarState

                newModel =
                    { model | calendarState = updatedCalendar }
            in
                case maybeMsg of
                    Nothing ->
                        ( newModel, Cmd.none )

                    Just updateMsg ->
                        update updateMsg newModel

        SelectDate date ->
            ( model, Cmd.none )

        WindowSize size ->
            ( { model | size = size }, Task.perform SetDate Date.now)


createPlanningRequest: Date.Date -> String -> Cmd Msg
createPlanningRequest date slug =
    -- sendRequest (toDatetime (Dateextra.add Dateextra.Month -7 date)) (toDatetime (Dateextra.add Dateextra.Month 7 date)) [ slug ]
    sendRequest (toDatetime date) (toDatetime (Dateextra.add Dateextra.Month 2 date)) [ slug ]
    -- Task.succeed (GraphQlMsg ( Ok createFakeQuery ) ) |> Task.perform identity


find : (a -> Bool) -> List a -> Maybe a
find predicate list =
    case list of
        [] ->
            Nothing

        first::rest ->
            if predicate first then
                Just first
            else
                find predicate rest


eventConfig : Calendar.EventConfig Msg
eventConfig =
    Calendar.eventConfig
        { onClick = \_ -> Nothing
        , onMouseEnter = \_ -> Nothing
        , onMouseLeave = \_ -> Nothing
        , onDragStart = \_ -> Nothing
        , onDragging = \_ _ -> Nothing
        , onDragEnd = \_ _ -> Nothing
        }


timeSlotConfig : Calendar.TimeSlotConfig Msg
timeSlotConfig =
    Calendar.timeSlotConfig
        { onClick = \date pos -> Just <| SelectDate date
        , onMouseEnter = \_ _ -> Nothing
        , onMouseLeave = \_ _ -> Nothing
        , onDragStart = \_ _ -> Nothing
        , onDragging = \_ _ -> Nothing
        , onDragEnd = \_ _ -> Nothing
        }
