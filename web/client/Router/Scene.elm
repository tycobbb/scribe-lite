module Router.Scene exposing (State, Model, Msg, init, update, view)

import Html exposing (Html)
import Css exposing (Color)
import Router.Route as Route
import Scenes.Story.Story as Story
import Scenes.Thanks.Thanks as Thanks
import Socket.Event exposing (Event)
import Helpers exposing (withoutEffects)

-- state
type alias State =
  ( Model, Cmd Msg, Event Msg )

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

toState : (a -> Scene) -> (b -> Msg) -> (( a, Cmd b, Event b ), Color) -> State
toState asScene asMsg ((submodel, cmd, event), color) =
  ( { scene = asScene submodel, color = color }
  , Cmd.map asMsg cmd
  , Socket.Event.map asMsg event
  )

-- init
init : Route.Route -> State
init route =
  case route of
    Route.Story ->
      ( Story.init, Story.background )
        |> toState Story StoryMsg
    Route.Thanks ->
      ( Thanks.init, Thanks.background )
        |> toState Thanks ThanksMsg

-- update
update : Msg -> Model -> State
update msg model =
  case ( msg, model.scene ) of
    ( StoryMsg msg, Story story ) ->
      ( Story.update msg story, model.color )
        |> toState Story StoryMsg
    ( ThanksMsg msg, Thanks thanks ) ->
      ( Thanks.update msg thanks, model.color )
        |> toState Thanks ThanksMsg
    _ ->
      withoutEffects model

-- view
view : Model -> Html Msg
view { scene } =
  case scene of
    Story story ->
      Html.map StoryMsg (Story.view story)
    Thanks thanks ->
      Html.map ThanksMsg (Thanks.view thanks)
