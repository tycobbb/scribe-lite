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
  | StartTransition
  | EndTransition
  | SceneMsg Scene.Msg
  | SocketMsg (Socket.Msg Msg)

update : Msg -> Model -> State
update msg model =
  case (msg, model.stage) of
    ( UrlChange location, Active scene ) ->
      initScene location
        |> withIndex (scene.index + 1)
        |> setScene (TransitionWait scene) (withoutCmd model)
        |> joinCmd (async StartTransition)
    ( SocketMsg msg, _ ) ->
      Socket.update msg model.socket
        |> setSocket model
    ( SceneMsg msg, Active scene ) ->
      Scene.update msg scene.model
        |> withIndex scene.index
        |> setScene Active (withoutCmd model)
    ( StartTransition, TransitionWait scene nextScene ) ->
      { model | stage = Transition scene nextScene }
        |> withCmd (delay duration EndTransition)
    ( EndTransition, Transition _ nextScene ) ->
      withoutCmd { model | stage = Active nextScene }
    _ ->
      withoutCmd model

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
keyedScene { model, index } animation =
  ( "scene-" ++ toString index
  , scene model animation
  )

scene : Scene.Model -> Maybe Classes -> Html Msg
scene model animation =
  let
    classes =
      case animation of
        Just animation ->
          styles.classes
            [ ( Scene, True )
            , ( animation, True )
            ]
        Nothing ->
          styles.class Scene
  in
    section [ classes ]
      [ Scene.view model
          |> Html.map SceneMsg
      ]

-- routing
initScene : Navigation.Location -> Scene.State
initScene location =
  Scene.init (Route.route location)

setScene : (IndexedScene -> Stage) -> State -> Indexed Scene.Model Scene.Msg -> State
setScene asStage (model, cmd) (scene, sceneCmd, sceneEvent) =
  let
    event =
      sceneEvent
        |> Socket.Event.map SceneMsg
  in
    ( { model | stage = asStage scene }, cmd )
      |> joinCmd (Cmd.map SceneMsg sceneCmd)
      |> sendEvent event

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
