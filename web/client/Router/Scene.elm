module Router.Scene exposing (State, Model(..), Msg, init, initEvent, update, updateEvent, view)

import Html exposing (Html)
import Router.Route as Route
import Story.Story as Story
import Socket.Event

-- state
type alias State =
  ( Model, Cmd Msg )

type Model
  = Story Story.Model
  | None

type Msg
  = StoryMsg Story.Msg

toState : (a -> Model) -> (b -> Msg) -> ( a, Cmd b ) -> State
toState asModel asMsg (submodel, msg) =
  ( asModel submodel, Cmd.map asMsg msg )

toEvent : (m -> Msg) -> Socket.Event.Event m -> Socket.Event.Event Msg
toEvent toMsg =
  Socket.Event.map toMsg

toView : (a -> msg) -> Html a -> Html msg
toView toMsg =
  Html.map toMsg

-- init
init : Route.Route -> ( Model, Cmd Msg )
init route =
  case route of
    Route.Story ->
      toState Story StoryMsg (Story.init)
    Route.Thanks ->
      ( None, Cmd.none )

initEvent : Model -> Socket.Event.Event Msg
initEvent scene =
  case scene of
    Story _ ->
      toEvent StoryMsg (Story.initEvent)
    _ -> Socket.Event.none

-- update
update : Msg -> Model -> State
update msg scene =
  case ( msg, scene ) of
    (StoryMsg msg, Story model) ->
      toState Story StoryMsg (Story.update msg model)
    _ ->
      (scene, Cmd.none)

updateEvent : Msg -> Model -> Socket.Event.Event Msg
updateEvent msg scene =
  case ( msg, scene ) of
    (StoryMsg msg, Story model) ->
      toEvent StoryMsg (Story.updateEvent msg model)
    _ ->
      Socket.Event.none

-- view
view : Model -> Html Msg
view scene =
  case scene of
    Story model ->
      toView StoryMsg (Story.view model)
    _ ->
      Html.text ""
