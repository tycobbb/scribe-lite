module Main exposing (main)

import Html exposing (..)
import Html.Keyed as Keyed
import Navigation
import Phoenix.Socket as Socket
import Router.Route as Route
import Router.Scene as Scene
import Socket.Event
import MainStyles exposing (Classes(..), styles, inline, duration)
import Helpers exposing (Indexed, withCmd, withoutCmd, joinCmd, withIndex, async, delay)

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
type alias State = ( Model, Cmd Msg )

type alias Model =
  { stage : Stage
  , socket : Socket.Socket Msg
  }

init : Navigation.Location -> State
init location =
  initScene location
    |> withIndex 0
    |> setScene Active (withoutCmd initModel)

initModel : Model
initModel =
  { stage = Blank
  , socket = initSocket
  }

-- stage
type Stage
  = Active IndexedScene
  | TransitionWait IndexedScene IndexedScene
  | Transition IndexedScene IndexedScene
  | Blank

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
      initScene location
        |> withIndex (scene.index + 1)
        |> setScene (Transition scene) (withoutCmd model)
        |> joinCmd (delay duration EndTransition)
    ( SocketMsg msg, _ ) ->
      Socket.update msg model.socket
        |> setSocket model
    ( SceneMsg index msg, Active scene ) ->
      updateScene msg scene
        |> setScene Active (withoutCmd model)
    ( SceneMsg index msg, TransitionWait scene nextScene ) ->
      if index == scene.index then
        updateScene msg scene
          |> setScene ((flip TransitionWait) nextScene) (withoutCmd model)
      else if index == nextScene.index then
        updateScene msg nextScene
          |> setScene (TransitionWait scene) (withoutCmd model)
      else
        withoutCmd model
    ( SceneMsg index msg, Transition scene nextScene ) ->
      if index == scene.index then
        updateScene msg scene
          |> setScene ((flip Transition) nextScene) (withoutCmd model)
      else if index == nextScene.index then
        updateScene msg nextScene
          |> setScene (Transition scene) (withoutCmd model)
      else
        withoutCmd model
    ( StartTransition, TransitionWait scene nextScene ) ->
      { model | stage = Transition scene nextScene }
        |> withCmd (delay duration EndTransition)
    ( EndTransition, Transition _ nextScene ) ->
      { model | stage = Active nextScene }
        |> withoutCmd
    _ ->
      withoutCmd model

updateScene : Scene.Msg -> IndexedScene -> Indexed Scene.Model Scene.Msg
updateScene msg scene =
  Scene.update msg scene.model
    |> withIndex scene.index

setSocket : Model -> (Socket.Socket Msg, Cmd (Socket.Msg Msg) ) -> State
setSocket model (field, cmd) =
  { model | socket = field }
    |> withCmd (Cmd.map SocketMsg cmd)

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
    TransitionWait scene nextScene ->
      keyedStage scene
        [ keyedScene scene Nothing
        , keyedScene nextScene (Just SceneIn)
        ]
    Transition scene nextScene ->
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
      [ Just Scene , animation ]
        |> List.filterMap identity
        |> List.map (\a -> ( a, True ))
  in
    section [ styles.classes classList ]
      [ Scene.view scene.model
          |> Html.map asMessage
      ]

-- routing
initScene : Navigation.Location -> Scene.State
initScene location =
  Scene.init (Route.route location)

setScene : (IndexedScene -> Stage) -> State -> Indexed Scene.Model Scene.Msg -> State
setScene asStage (model, cmd) (scene, sceneCmd, sceneEvent) =
  let
    asMessage =
      SceneMsg scene.index
  in
    ( { model | stage = asStage scene }, cmd )
      |> joinCmd (Cmd.map asMessage sceneCmd)
      |> sendEvent (Socket.Event.map asMessage sceneEvent)

-- socket
initSocket : Socket.Socket msg
initSocket =
  Socket.init serverUrl
    |> Socket.withDebug

sendEvent : Socket.Event.Event Msg -> State -> State
sendEvent event (model, cmd)  =
  let
    (socket, socketCmd) =
      Socket.Event.send model.socket event
  in
    ( { model | socket = socket }, cmd )
      |> joinCmd (Cmd.map SocketMsg socketCmd)
