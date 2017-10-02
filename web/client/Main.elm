module Main exposing (main)

import Html exposing (..)
import Phoenix.Socket as Socket
import MainStyles exposing (Classes(..), styles)
import Story.Story as Story
import Socket.Event

-- main
main : Program Never Model Msg
main =
  program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- constants
serverUrl : String
serverUrl = "ws://localhost:4000/socket/websocket"

-- state
type alias State =
  (Model, Cmd Msg)

type alias Model =
  { socket : Socket.Socket Msg
  , story : Story.Model
  }

init : State
init =
  let
    (story, storyCmd, storyEvent) =
      Story.init
    state =
      ( { socket = initSocket
        , story = story
        }
      , Cmd.map StoryMsg storyCmd
      )
  in
    state
      |> sendEvent StoryMsg storyEvent

-- update
type Msg
  = SocketMsg (Socket.Msg Msg)
  | StoryMsg Story.Msg

update : Msg -> Model -> State
update action model =
  case action of
    SocketMsg msg ->
      Socket.update msg model.socket
        |> setSocket model
    StoryMsg action ->
      Story.update action model.story
        |> setStory model

setSocket : Model -> (Socket.Socket Msg, Cmd (Socket.Msg Msg) ) -> (Model, Cmd Msg)
setSocket model (field, cmd) =
  ({ model | socket = field }, Cmd.map SocketMsg cmd)

setStory : Model -> Story.State -> State
setStory model (field, cmd, event) =
  ({ model | story = field }, Cmd.map StoryMsg cmd)
    |> sendEvent StoryMsg event

-- subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
   Socket.listen model.socket SocketMsg

-- view
{ class } = styles

view : Model -> Html Msg
view model =
  div [ class Container ]
    [ Story.view model.story
        |> Html.map StoryMsg
    ]

-- socket
initSocket : Socket.Socket msg
initSocket =
  Socket.init serverUrl
    |> Socket.withDebug

sendEvent : (m -> Msg) -> Socket.Event.Event m -> State -> State
sendEvent message event (model, cmd)  =
  let
    (socket, socketCmd) =
      event
        |> Socket.Event.map message
        |> Socket.Event.send model.socket
  in
    ( { model | socket = socket }
    , Cmd.batch
      [ cmd
      , Cmd.map SocketMsg socketCmd
      ]
     )
