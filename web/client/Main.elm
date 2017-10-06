module Main exposing (main)

import Html exposing (..)
import Navigation
import Phoenix.Socket as Socket
import MainStyles exposing (Classes(..), styles)
import Router.Route as Route
import Router.Scene as Scene
import Socket.Event

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
init location =
  setLocation location
    ( { scene = Scene.None
      , socket = initSocket
      }
    , Cmd.none
    )

-- update
type Msg
  = UrlChange Navigation.Location
  | SceneMsg Scene.Msg
  | SocketMsg (Socket.Msg Msg)

update : Msg -> Model -> State
update msg model =
  case msg of
    UrlChange location ->
      setLocation location ( model, Cmd.none )
    SceneMsg msg ->
      setScene
        (Scene.update msg model.scene)
        (Scene.updateEvent msg)
        ( model, Cmd.none )
    SocketMsg msg ->
      Socket.update msg model.socket
        |> setSocket model

setSocket : Model -> (Socket.Socket Msg, Cmd (Socket.Msg Msg) ) -> State
setSocket model (field, cmd) =
  ( { model | socket = field }, Cmd.map SocketMsg cmd )

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
setLocation : Navigation.Location -> State -> State
setLocation location =
  setScene
    (Scene.init (Route.route location))
    (Scene.initEvent)

setScene : Scene.State -> (Scene.Model -> Socket.Event.Event Scene.Msg) -> State -> State
setScene (scene, sceneCmd) getEvent (model, cmd) =
  let
    event =
      getEvent scene
        |> Socket.Event.map SceneMsg
    state =
      ( { model | scene = scene }
      , Cmd.batch
        [ cmd
        , Cmd.map SceneMsg sceneCmd
        ]
      )
  in
    state |>
      sendEvent event

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
    ( { model | socket = socket }
    , Cmd.batch
      [ cmd
      , Cmd.map SocketMsg socketCmd
      ]
     )
