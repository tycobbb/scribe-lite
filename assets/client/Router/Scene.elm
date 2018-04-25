module Router.Scene exposing (State, Model, Msg, init, update, view)

import Html exposing (Html)
import Css exposing (Color)
import Router.Route as Route
import Scenes.Story.Story as Story
import Scenes.Thanks.Thanks as Thanks
import Helpers exposing (Change, mapChange, withoutEffects)

-- state
type alias State =
  Change Model Msg

type alias Model =
  { scene : Scene
  , color : Color
  }

type Scene
  = Story Story.Model
  | Thanks Thanks.Model

type Msg
  = StoryMsg Story.Msg
  | ThanksMsg Thanks.Msg

toState : (a -> Scene) -> (m -> Msg) -> Color -> Change a m -> Change Model Msg
toState asModel asMsg color =
  (mapChange asModel asMsg) >> (setColor color)

-- init
init : Route.Route -> State
init route =
  case route of
    Route.Story ->
      Story.init
        |> toState Story StoryMsg Story.background
    Route.Thanks ->
      Thanks.init
        |> toState Thanks ThanksMsg Thanks.background

-- update
update : Msg -> Model -> State
update msg model =
  case ( msg, model.scene ) of
    ( StoryMsg msg, Story story ) ->
      Story.update msg story
        |> toState Story StoryMsg Story.background
    ( ThanksMsg msg, Thanks thanks ) ->
      Thanks.update msg thanks
        |> toState Thanks ThanksMsg Thanks.background
    _ ->
      withoutEffects model

setColor : Color -> Change Scene Msg -> Change Model Msg
setColor color { model, effects } =
  { model = Model model color
  , effects = effects
  }

-- view
view : Model -> Html Msg
view { scene } =
  case scene of
    Story story ->
      Story.view story
        |> Html.map StoryMsg
    Thanks thanks ->
      Thanks.view thanks
        |> Html.map ThanksMsg
