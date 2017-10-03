module Main exposing (main)

import Html exposing (..)
import Navigation
import Phoenix.Socket as Socket
import MainStyles exposing (Classes(..), styles)
import Router exposing (Route)
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
  { scene : Scene
  , socket : Socket.Socket Msg
  }

init : Navigation.Location -> State
init _ =
  ( { scene = None
    , socket = initSocket
    }
  , Cmd.none
  )

-- update
type Msg
  = UrlChange Navigation.Location
  | SceneMsg1 SceneMsg
  -- | StoryMsg Story.Msg
  | SocketMsg (Socket.Msg Msg)

update : Msg -> Model -> State
update msg model =
  case msg of
    UrlChange location ->
      let _ = Debug.log "now at" (toString location) in
      ( model, Cmd.none )
    SceneMsg1 _ ->
      ( model, Cmd.none )
    -- StoryMsg msg ->
    --   Story.update msg model.story
    --     |> setStory model
    --     |> sendEvent StoryMsg (Story.updateEvent msg model.story)
    SocketMsg msg ->
      Socket.update msg model.socket
        |> setSocket model

setSocket : Model -> (Socket.Socket Msg, Cmd (Socket.Msg Msg) ) -> State
setSocket model (field, cmd) =
  ( { model | socket = field }, Cmd.map SocketMsg cmd )

-- setStory : Model -> Story.State -> State
-- setStory model (field, cmd) =
--   ( { model | story = field }, Cmd.map StoryMsg cmd )

-- subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
   Socket.listen model.socket SocketMsg

-- view
{ class } = styles

view : Model -> Html Msg
view model =
  div [ class Container ]
    []
    -- [ Story.view model.story
    --     |> Html.map StoryMsg
    -- ]

-- scene
type Scene
  = Story
  | Thanks
  | None

type SceneMsg
  = StoryMsg Story.Msg

-- scene : Router.Route -> Scene
-- scene route =
--   case route of
--     Router.Story ->
--       let
--         (model, cmd) = Story.init
--       in
--         Story model
--           -- { initCmd = Story.init
--           -- , initEvent = Story.initEvent
--           -- , update = Story.update
--           -- , updateEvent = Story.updateEvent
--           -- , view = Story.view
--           -- }
--     Router.Thanks ->
--       None

initS : ( { b | scene : a }, Cmd SceneMsg ) -> ( { b | scene : Scene }, Cmd SceneMsg )
initS (model, cmd) =
  let
    (story, storyCmd) = Story.init
  in
    ( { model | scene = Story }
    , Cmd.batch
      [ cmd
      , Cmd.map StoryMsg storyCmd
      ]
    )

updateS : (Story.Model, Story.Msg) -> State -> State
updateS (story, storyMsg) (model, cmd) =
  let
    (story_, storyCmd) = Story.update storyMsg story
    event = Story.updateEvent storyMsg story
      |> Socket.Event.map StoryMsg
      |> Socket.Event.map SceneMsg1

  in
    ( { model | scene = Story }
    , Cmd.batch
      [ cmd
      , Cmd.map StoryMsg storyCmd
          |> Cmd.map SceneMsg1
      ]
    )
    |> sendEvent event

viewS : Story.Model -> Html Msg
viewS story =
  Story.view story
    |> Html.map StoryMsg
    |> Html.map SceneMsg1

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
