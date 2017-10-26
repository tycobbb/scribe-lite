module Main exposing (main)

import Html exposing (..)
import Html.Keyed as Keyed
import Navigation
import Phoenix.Socket as Socket
import Router.Route as Route
import Router.Scene as Scene
import Socket.Event
import MainStyles exposing (Classes(..), styles, inline, duration)
import Helpers exposing (Change, Effects, Indexed, withCmd, withoutCmd, joinCmd, withIndex, mapEffects, async, delay)

-- main
main : Program Never Model Msg
main =
  Navigation.program UrlChange
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- constants
serverUrl : String
serverUrl =
  "ws://localhost:4000/socket/websocket"

-- state
type alias State =
  ( Model, Cmd Msg )

type alias Model =
  { stage : Stage
  , socket : Socket.Socket Msg
  }

init : Navigation.Location -> State
init location =
  withoutCmd initModel
    |> setScene Active (initScene location 0)

initModel : Model
initModel =
  { stage = Blank
  , socket = initSocket
  }

-- stage
type Stage
  = Active IndexedScene
  | TransitionWait IndexedScenes
  | Transition IndexedScenes
  | Blank

type alias IndexedScenes =
  { scene : IndexedScene
  , nextScene : IndexedScene
  }

type alias IndexedScene =
  { index : Int
  , model : Scene.Model
  }

-- update
type Msg
  = UrlChange Navigation.Location
  | SocketMsg (Socket.Msg Msg)
  | SceneMsg Int Scene.Msg
  | StartTransition
  | EndTransition

update : Msg -> Model -> State
update msg model =
  case (msg, model.stage) of
    ( UrlChange location, Active scene ) ->
      withoutCmd model
        |> setScene (stageFrom scene Transition) (initScene location (scene.index + 1))
        |> joinCmd (delay duration EndTransition)
    ( SocketMsg msg, _ ) ->
      withoutCmd model
        |> setSocket (Socket.update msg model.socket)
    ( SceneMsg index msg, Active scene ) ->
      withoutCmd model
        |> setScene Active (updateScene msg scene)
    ( SceneMsg index msg, TransitionWait scenes ) ->
      withoutCmd model
        |> updateScenes TransitionWait index msg scenes
    ( SceneMsg index msg, Transition scenes ) ->
      withoutCmd model
        |> updateScenes Transition index msg scenes
    ( StartTransition, TransitionWait scenes ) ->
      { model | stage = Transition scenes }
        |> withCmd (delay duration EndTransition)
    ( EndTransition, Transition scenes ) ->
      { model | stage = Active scenes.nextScene }
        |> withoutCmd
    _ ->
      withoutCmd model

-- subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
  Socket.listen model.socket SocketMsg

-- view
{ class } = styles

view : Model -> Html Msg
view { stage } =
  case stage of
    Active scene ->
      keyedStage scene
        [ keyedScene scene Nothing
        ]
    TransitionWait { scene, nextScene } ->
      keyedStage scene
        [ keyedScene scene Nothing
        , keyedScene nextScene (Just SceneIn)
        ]
    Transition { scene, nextScene } ->
      keyedStage nextScene
        [ keyedScene scene (Just SceneOut)
        , keyedScene nextScene Nothing
        ]
    Blank ->
      div [ class Stage ]
        [ text ""
        ]

keyedStage : IndexedScene -> List ( String, Html m ) -> Html m
keyedStage { model } =
  Keyed.node "div"
    [ class Stage
    , inline.backgroundColor model.color
    ]

keyedScene : IndexedScene -> Maybe Classes -> ( String, Html Msg )
keyedScene scene animation =
  ( "scene-" ++ toString scene.index
  , sceneView scene animation
  )

sceneView : IndexedScene -> Maybe Classes -> Html Msg
sceneView scene animation =
  let
    asMessage =
      SceneMsg scene.index
    classList =
      [ Just Scene, animation ]
        |> List.filterMap identity
        |> List.map (\a -> ( a, True ))
  in
    section [ styles.classes classList ]
      [ Scene.view scene.model
          |> Html.map asMessage
      ]

-- scenes
initScene : Navigation.Location -> Int -> Change IndexedScene Scene.Msg
initScene location index =
  Scene.init (Route.route location)
    |> withIndex index

setScene : (IndexedScene -> Stage) -> Change IndexedScene Scene.Msg -> State -> State
setScene asStage sceneState ( model, cmd ) =
  let
    asMsg =
      (SceneMsg sceneState.model.index)
  in
    { model | stage = asStage sceneState.model }
      |> withCmd cmd
      |> joinEffects (mapEffects asMsg sceneState.effects)

updateScenes : (IndexedScenes -> Stage) -> Int -> Scene.Msg -> IndexedScenes -> State -> State
updateScenes asStage index msg { scene, nextScene } =
  if index == scene.index then
    setScene (stageTo nextScene asStage) (updateScene msg scene)
  else if index == nextScene.index then
    setScene (stageFrom scene asStage) (updateScene msg nextScene)
  else
    identity

updateScene : Scene.Msg -> IndexedScene -> Change IndexedScene Scene.Msg
updateScene msg scene =
  Scene.update msg scene.model
    |> withIndex scene.index

joinEffects : Effects Msg -> State -> State
joinEffects ( cmd, event ) =
  joinCmd cmd
    >> sendEvent event

-- socket
initSocket : Socket.Socket msg
initSocket =
  Socket.init serverUrl
    |> Socket.withDebug

setSocket : ( Socket.Socket Msg, Cmd (Socket.Msg Msg) ) -> State -> State
setSocket ( socket, socketCmd ) ( model, cmd ) =
  { model | socket = socket }
    |> withCmd cmd
    |> joinCmd (Cmd.map SocketMsg socketCmd)

sendEvent : Socket.Event.Event Msg -> State -> State
sendEvent event (model, cmd)  =
  let
    (socket, socketCmd) =
      Socket.Event.send model.socket event
  in
    { model | socket = socket }
      |> withCmd cmd
      |> joinCmd (Cmd.map SocketMsg socketCmd)

-- transitions
stageFrom : IndexedScene -> (IndexedScenes -> Stage) -> IndexedScene -> Stage
stageFrom scene asStage =
  (IndexedScenes scene) >> asStage

stageTo : IndexedScene -> (IndexedScenes -> Stage) -> IndexedScene -> Stage
stageTo scene asStage =
  ((flip IndexedScenes) scene) >> asStage
