module Router.Scene exposing (State, Model, Msg, init, subscriptions, update, view)

import Css
import Html.Styled as H exposing (Html)

import Router.Route as Route
import Scenes.Story.Story as Story
import Scenes.Thanks.Thanks as Thanks
import Session exposing (Session)
import State

-- state
type alias State =
  State.Base Model Msg

type alias Model =
  { color : Css.Color
  , scene : Scene
  }

type Scene
  = Story  Story.Model
  | Thanks Thanks.Model
  | NotFound

type Msg
  = StoryMsg  Story.Msg
  | ThanksMsg Thanks.Msg

toState : (a -> Scene) -> (m -> Msg) -> Css.Color -> (a, Cmd m) -> State
toState toScene toMsg color =
  State.map (toScene >> (Model color)) toMsg

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
    Route.NotFound ->
      { scene = NotFound, color = Css.hex "FF0000" }
        |> State.withoutCmd

-- subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
  case model.scene of
    Story story ->
      Story.subscriptions story
        |> Sub.map StoryMsg
    _ ->
      Sub.none

-- update
update : Msg -> Model -> Session -> State
update msgBox model session =
  case ( msgBox, model.scene ) of
    ( StoryMsg msg, Story story ) ->
      Story.update msg story session
        |> toState Story StoryMsg Story.background
    ( ThanksMsg msg, Thanks thanks ) ->
      Thanks.update msg thanks session
        |> toState Thanks ThanksMsg Thanks.background
    _ ->
      State.just model

-- view
view : Model -> Html Msg
view { scene } =
  case scene of
    Story story ->
      Story.view story
        |> H.map StoryMsg
    Thanks thanks ->
      Thanks.view thanks
        |> H.map ThanksMsg
    NotFound ->
      H.text "not found."
