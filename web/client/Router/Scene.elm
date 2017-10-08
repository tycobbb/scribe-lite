module Router.Scene exposing (State, Model(..), Msg, init, update, view)

import Html exposing (Html)
import Router.Route as Route
import Story.Story as Story
import Socket.Event exposing (Event)
import Helpers exposing (withoutEffects)

-- state
type alias State =
  ( Model, Cmd Msg, Event Msg )

type Model
  = Story Story.Model
  | None

type Msg
  = StoryMsg Story.Msg

toState : (a -> Model) -> (b -> Msg) -> ( a, Cmd b, Event b ) -> State
toState asModel asMsg (submodel, cmd, event) =
  ( asModel submodel
  , Cmd.map asMsg cmd
  , Socket.Event.map asMsg event
  )

-- init
init : Route.Route -> State
init route =
  case route of
    Route.Story ->
      toState Story StoryMsg (Story.init)
    Route.Thanks ->
      withoutEffects None

-- update
update : Msg -> Model -> State
update msg scene =
  case ( msg, scene ) of
    (StoryMsg msg, Story model) ->
      toState Story StoryMsg (Story.update msg model)
    _ ->
      withoutEffects scene

-- view
view : Model -> Html Msg
view scene =
  case scene of
    Story model ->
      Html.map StoryMsg (Story.view model)
    _ ->
      Html.text ""
