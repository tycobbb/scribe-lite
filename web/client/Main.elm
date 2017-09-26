module Main exposing (main)

import Html exposing (..)
import Phoenix.Socket as Socket
import Phoenix.Channel as Channel
import Phoenix.Push as Push
import MainStyles exposing (Classes(..), styles)
import Story.Story as Story

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
serverUrl = "ws://localhost:4000/socket"

-- model
type alias Model =
  { socket : Socket.Socket Action
  , story : Story.Model
  }

init : (Model, Cmd Action)
init =
  let
    (story, storyCmd) = Story.init
    (socket, socketCmd) =
      initSocket
        |> Socket.join (Channel.map StoryAction Story.initChannel)
  in
    ( { socket = socket
      , story = story
      }
    , Cmd.batch
      [ Cmd.map SocketMsg socketCmd
      , Cmd.map StoryAction storyCmd
      ]
    )

initSocket : Socket.Socket msg
initSocket =
  Socket.init "ws://localhost:4000/socket/websocket"
    |> Socket.withDebug

-- update
type Action
  = SocketMsg (Socket.Msg Action)
  | StoryAction Story.Action

update : Action -> Model -> (Model, Cmd Action)
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

setStory : Model -> (Story.Model, Cmd Story.Action) -> (Model, Cmd Action)
setStory model (field, cmd) =
  ({ model | story = field }, Cmd.map StoryAction cmd)

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
