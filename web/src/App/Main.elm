module Main exposing (main)

import Html exposing (..)
import Html.Keyed as Keyed
import Router.Route as Route
import Router.Scene as Scene
import Socket.Event
import MainStyles exposing (Classes(..), styles, inline, duration)
import Helpers exposing (..)

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
  | Transition Bool IndexedScenes
  | Blank

type alias IndexedScenes =
  { scene : IndexedScene
  , nextScene : IndexedScene
  }

type alias IndexedScene =
  Indexed Scene.Model

-- update
type Msg
  = UrlChange Navigation.Location
  | SocketMsg (Socket.Msg Msg)
  | SceneMsg (Indexed Scene.Msg)
  | StartTransition
  | EndTransition

update : Msg -> Model -> State
update msg model =
  case (msg, model.stage) of
    ( UrlChange location, Active scene ) ->
      withoutCmd model
        |> setScene (stageFrom scene (Transition False)) (initScene location (scene.index + 1))
        |> joinCmd (async StartTransition)
    ( SocketMsg msg, _ ) ->
      withoutCmd model
        |> setSocket (Socket.update msg model.socket)
    ( SceneMsg msg, Active scene ) ->
      withoutCmd model
        |> updateScene Active msg scene
    ( SceneMsg msg, Transition isActive scenes ) ->
      withoutCmd model
        |> updateScenes (Transition isActive) msg scenes
    ( StartTransition, Transition False scenes ) ->
      { model | stage = Transition True scenes }
        |> withCmd (delay duration EndTransition)
    ( EndTransition, Transition True scenes ) ->
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
    Transition False { scene, nextScene } ->
      keyedStage scene
        [ keyedScene scene (Just SceneReady)
        , keyedScene nextScene (Just SceneIn)
        ]
    Transition True { scene, nextScene } ->
      keyedStage nextScene
        [ keyedScene scene (Just SceneOut)
        , keyedScene nextScene (Just SceneReady)
        ]
    Blank ->
      div [ class Stage ]
        [ text ""
        ]

keyedStage : IndexedScene -> List ( String, Html m ) -> Html m
keyedStage { item } =
  Keyed.node "div"
    [ class Stage
    , inline.backgroundColor item.color
    ]

keyedScene : IndexedScene -> Maybe Classes -> ( String, Html Msg )
keyedScene scene animation =
  ( "scene-" ++ toString scene.index
  , sceneView scene animation
  )

sceneView : IndexedScene -> Maybe Classes -> Html Msg
sceneView scene animation =
  section [ sceneClasses animation ]
    [ Scene.view scene.item
        |> Html.map (indexable SceneMsg scene.index)
    ]

sceneClasses : Maybe Classes -> Attribute m
sceneClasses animation =
  [ Just Scene, animation ]
    |> List.filterMap identity
    |> List.map (\a -> ( a, True ))
    |> styles.classes

-- scenes
initScene : Navigation.Location -> Int -> Change IndexedScene Scene.Msg
initScene location index =
  Scene.init (Route.route location)
    |> withIndex index

setScene : (IndexedScene -> Stage) -> Change IndexedScene Scene.Msg -> State -> State
setScene asStage sceneState ( model, cmd ) =
  { model | stage = asStage sceneState.model }
    |> withCmd cmd
    |> joinEffects (mapEffects (asSceneMsg sceneState.model.index) sceneState.effects)

updateScenes : (IndexedScenes -> Stage) -> Indexed Scene.Msg -> IndexedScenes -> State -> State
updateScenes asStage msg { scene, nextScene } =
  if msg.index == scene.index then
    updateScene (stageTo nextScene asStage) msg scene
  else if msg.index == nextScene.index then
    updateScene (stageFrom scene asStage) msg nextScene
  else
    identity

updateScene : (IndexedScene -> Stage) -> Indexed Scene.Msg -> IndexedScene -> State -> State
updateScene asStage msg scene =
  Scene.update msg.item scene.item
    |> withIndex scene.index
    |> setScene asStage

joinEffects : Effects Msg -> State -> State
joinEffects ( cmd, event ) =
  joinCmd cmd
    >> sendEvent event

asSceneMsg : Int -> Scene.Msg -> Msg
asSceneMsg =
  indexable SceneMsg

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
