module Main exposing (main)

import Html exposing (..)
import Navigation
import Phoenix.Socket as Socket
import Router.Route as Route
import Router.Scene as Scene
import Socket.Event
import MainStyles exposing (Classes(..), styles)
import Helpers exposing (withCmd, withoutCmd, joinCmd, async, delay)

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

type Stage
  = Active Scene.Model
  | TransitionWait Scene.Model Scene.Model
  | Transition Scene.Model Scene.Model
  | Blank

init : Navigation.Location -> State
init location =
  initScene location
    |> setScene Active (withoutCmd initModel)

initModel : Model
initModel =
  { stage = Blank
  , socket = initSocket
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
        |> setScene (TransitionWait scene) (withoutCmd model)
        |> joinCmd (async StartTransition)
    ( SocketMsg msg, _ ) ->
      Socket.update msg model.socket
        |> setSocket model
    ( SceneMsg msg, Active scene ) ->
      Scene.update msg scene
        |> setScene Active (withoutCmd model)
    ( StartTransition, TransitionWait scene nextScene ) ->
      { model | stage = Transition scene nextScene }
        |> withoutCmd
        -- |> withCmd (delay 200 EndTransition)
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
view model =
  div [ class Stage ]
    (viewStage model.stage)

viewStage : Stage -> List (Html Msg)
viewStage stage =
  case stage of
    Active scene ->
      [ viewScene scene True
      ]
    TransitionWait scene nextScene ->
      [ viewScene scene True
      , viewScene nextScene False
      ]
    Transition scene nextScene ->
      [ viewScene scene False
      , viewScene nextScene True
      ]
    Blank ->
      [ text ""
      ]

viewScene : Scene.Model -> Bool -> Html Msg
viewScene scene isVisible =
  section
    [ styles.classes
      [ ( Scene, True )
      , ( Visible, isVisible )
      ]
    ]
    [ Scene.view scene
        |> Html.map SceneMsg
    ]

-- routing
initScene : Navigation.Location -> Scene.State
initScene location =
  Scene.init (Route.route location)

setScene : (Scene.Model -> Stage) -> State -> Scene.State -> State
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
