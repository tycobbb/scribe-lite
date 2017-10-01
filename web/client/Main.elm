module Main exposing (main)

import Html exposing (..)
import Phoenix.Socket as Socket
import MainStyles exposing (Classes(..), styles)
import Story.Story as Story
import Socket.Event

-- main
main : Program Never Model Action
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
  (Model, Cmd Action)

type alias Model =
  { socket : Socket.Socket Action
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
      , Cmd.map StoryAction storyCmd
      )
  in
    state
      |> sendEvent StoryAction storyEvent

-- update
type Action
  = SocketMsg (Socket.Msg Action)
  | StoryAction Story.Action

update : Action -> Model -> State
update action model =
  case action of
    SocketMsg msg ->
      Socket.update msg model.socket
        |> setSocket model
    StoryAction action ->
      Story.update action model.story
        |> setStory model

setSocket : Model -> (Socket.Socket Action, Cmd (Socket.Msg Action) ) -> (Model, Cmd Action)
setSocket model (field, cmd) =
  ({ model | socket = field }, Cmd.map SocketMsg cmd)

setStory : Model -> Story.State -> State
setStory model (field, cmd, event) =
  ({ model | story = field }, Cmd.map StoryAction cmd)
    |> sendEvent StoryAction event

-- subscriptions
subscriptions : Model -> Sub Action
subscriptions model =
   Socket.listen model.socket SocketMsg

-- view
{ class } = styles

view : Model -> Html Action
view model =
  div [ class Container ]
    [ Story.view model.story
        |> Html.map StoryAction
    ]

-- socket
initSocket : Socket.Socket msg
initSocket =
  Socket.init serverUrl
    |> Socket.withDebug

sendEvent : (m -> Action) -> Socket.Event.Event m -> State -> State
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
