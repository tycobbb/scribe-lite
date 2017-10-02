module Main exposing (main)

import Html exposing (..)
import Navigation
import Phoenix.Socket as Socket
import MainStyles exposing (Classes(..), styles)
import Story.Story as Story
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
  { socket : Socket.Socket Msg
  , story : Story.Model
  }

init : Navigation.Location -> State
init _ =
  let
    (story, storyCmd) =
      Story.init
    state =
      ( { socket = initSocket
        , story = story
        }
      , Cmd.map StoryMsg storyCmd
      )
  in
    state
      |> sendEvent StoryMsg Story.initEvent

-- update
type Msg
  = UrlChange Navigation.Location
  | StoryMsg Story.Msg
  | SocketMsg (Socket.Msg Msg)

update : Msg -> Model -> State
update msg model =
  case msg of
    UrlChange location ->
      let _ = Debug.log "now at" (toString location) in
      ( model, Cmd.none )
    StoryMsg msg ->
      Story.update msg model.story
        |> setStory model
        |> sendEvent StoryMsg (Story.updateEvent msg model.story)
    SocketMsg msg ->
      Socket.update msg model.socket
        |> setSocket model

setSocket : Model -> (Socket.Socket Msg, Cmd (Socket.Msg Msg) ) -> State
setSocket model (field, cmd) =
  ( { model | socket = field }, Cmd.map SocketMsg cmd )

setStory : Model -> Story.State -> State
setStory model (field, cmd) =
  ( { model | story = field }, Cmd.map StoryMsg cmd )

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
sendEvent msg event (model, cmd)  =
  let
    (socket, socketCmd) =
      event
        |> Socket.Event.map msg
        |> Socket.Event.send model.socket
  in
    ( { model | socket = socket }
    , Cmd.batch
      [ cmd
      , Cmd.map SocketMsg socketCmd
      ]
     )
