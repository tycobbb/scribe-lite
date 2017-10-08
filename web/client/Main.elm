module Main exposing (main)

import Html exposing (..)
import Navigation
import Phoenix.Socket as Socket
import MainStyles exposing (Classes(..), styles)
import Router.Route as Route
import Router.Scene as Scene
import Socket.Event
import Helpers exposing (withCmd, withoutCmd, joinCmd)

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
serverUrl = "ws://localhost:4000/socket/websocket"

-- state
type alias State = (Model, Cmd Msg)

type alias Model =
  { scene : Scene.Model
  , socket : Socket.Socket Msg
  }

init : Navigation.Location -> State
init =
  setLocation (withoutCmd initModel)

initModel : Model
initModel =
  { scene = Scene.None
  , socket = initSocket
  }

-- update
type Msg
  = UrlChange Navigation.Location
  | SceneMsg Scene.Msg
  | SocketMsg (Socket.Msg Msg)

update : Msg -> Model -> State
update msg model =
  case msg of
    UrlChange location ->
      location
        |> setLocation (withoutCmd model)
    SceneMsg msg ->
      Scene.update msg model.scene
        |> setScene (withoutCmd model)
    SocketMsg msg ->
      Socket.update msg model.socket
        |> setSocket model

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
  div [ class Container ]
    [ Scene.view model.scene
        |> Html.map SceneMsg
    ]

-- routing
setLocation : State -> Navigation.Location -> State
setLocation state location =
  Scene.init (Route.route location)
    |> setScene state

setScene : State -> Scene.State -> State
setScene (model, cmd) (scene, sceneCmd, sceneEvent) =
  let
    event =
      sceneEvent
        |> Socket.Event.map SceneMsg
  in
    ( { model | scene = scene }, cmd )
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
