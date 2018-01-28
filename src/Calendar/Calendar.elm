module Calendar.Calendar
    exposing
        ( init
        , update
        , page
        , changeTimeSpan
        , view
        , viewConfig
        , ViewConfig
        , EventView
        , eventView
        )

{-|

Hey it's a calendar!

# Definition
@docs init, State, TimeSpan

# Update
@docs Msg, update, page, changeTimeSpan, eventConfig, EventConfig, timeSlotConfig, TimeSlotConfig, subscriptions

# View
@docs view, viewConfig, ViewConfig, EventView, eventView
-}

import Html exposing (..)
import Date exposing (Date)
import Calendar.Config as Config
import Calendar.Internal as Internal exposing (State)
import Calendar.Msg as InternalMsg exposing (Msg, TimeSpan(..))

{-| Create the calendar
-}
init : TimeSpan -> Date -> State
init timeSpan viewing =
    Internal.init timeSpan viewing


{-| oh yes, please solve my UI update problems
-}
update : Msg -> State -> State
update msg state =
    let
        updatedCalendar =
            Internal.update msg state
    in
        updatedCalendar


{-| Page by some interval based on the current view: Month, Week, Day
-}
page : Int -> State -> State
page step state =
    Internal.page step state


{-| Change between views like Month, Week, Day, etc.
-}
changeTimeSpan : TimeSpan -> State -> State
changeTimeSpan timeSpan state =
    Internal.changeTimeSpan timeSpan state


{-| Show me the money
-}
view : ViewConfig event -> List event -> State -> Html Msg
view (ViewConfig config) events state =
    Internal.view config events state


{-| configure view definition
-}
type ViewConfig event
    = ViewConfig (Config.ViewConfig event)


{-| event view type
-}
type EventView
    = EventView Config.EventView


{-| configure a custom event view
-}
eventView :
    { nodeName : String
    , classes : List ( String, Bool )
    , children : List (Html InternalMsg.Msg)
    }
    -> EventView
eventView { nodeName, classes, children } =
    EventView
        { nodeName = nodeName
        , classes = classes
        , children = children
        }


{-| configure the view
-}
viewConfig :
    { toId : event -> String
    , title : event -> String
    , start : event -> Date
    , end : event -> Date
    , classrooms : event -> (List String)
    , teachers : event -> (List String)
    , groups : event -> (List String)
    , event : event -> Bool -> EventView
    }
    -> ViewConfig event
viewConfig { toId, title, start, end, classrooms, teachers, groups, event } =
    let
        extractEventView eventView =
            case eventView of
                EventView eventView_ ->
                    eventView_

        eventView id selected =
            extractEventView <| event id selected
    in
        ViewConfig
            { toId = toId
            , title = title
            , start = start
            , end = end
            , classrooms = classrooms
            , teachers = teachers
            , groups = groups
            , event = eventView
            }
