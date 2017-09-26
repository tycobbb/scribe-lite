module Main exposing (main)

import Html exposing (..)
import Phoenix.Socket as Socket
import Phoenix.Channel
import Phoenix.Push
import MainStyles exposing (Classes(..), styles)
import Compose.Compose as Compose

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
  , compose : Compose.Model
  }

init : (Model, Cmd Action)
init =
  let
    (compose, composeCmd) = Compose.init
  in
    ( { socket = Socket.init "ws://localhost:4000/socket"
      , compose = compose
      }
    , Cmd.map ComposeAction composeCmd
    )

-- update
type Action
  = SocketMsg (Socket.Msg Action)
  | ComposeAction Compose.Action

update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    SocketMsg msg ->
      Socket.update msg model.socket
        |> setSocket model
    ComposeAction action ->
      Compose.update action model.compose
        |> setCompose model

setSocket : Model -> (Socket.Socket Action, Cmd (Socket.Msg Action) ) -> (Model, Cmd Action)
setSocket model (field, cmd) =
  ({ model | socket = field }, Cmd.map SocketMsg cmd)

setCompose : Model -> (Compose.Model, Cmd Compose.Action) -> (Model, Cmd Action)
setCompose model (field, cmd) =
  ({ model | compose = field }, Cmd.map ComposeAction cmd)

-- subscriptions
subscriptions : Model -> Sub Action
subscriptions model =
   Socket.listen model.socket SocketMsg

-- view
{ class } = styles

view : Model -> Html Action
view model =
  div [ class Container ]
    [ Compose.view model.compose
        |> Html.map ComposeAction
    ]
