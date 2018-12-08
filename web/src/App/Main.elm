module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html.Styled as H
import Json.Encode as JE
import Url exposing (Url)

import Stage
import State
import Styles.Theme as Theme
import Session exposing (Session)

-- main
main : Program (Maybe Int) Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlChange = ChangedUrl
    , onUrlRequest = ClickedLink
    }

-- constants
serverUrl : String
serverUrl =
  "ws://localhost:4000/socket/websocket"

-- state
type alias State =
  State.Base Model Msg

type alias Model =
  { stage      : Stage.Model
  , sceneIndex : Int
  , session    : Session
  }

init _ url key =
  Stage.init url
    |> State.map (initModel key) StageMsg

initModel : Nav.Key -> Stage.Model -> Model
initModel key stage =
  { stage      = stage
  , sceneIndex = 0
  , session    = Session key
  }

setStage : Stage.Model -> Model -> Model
setStage stage model =
  { model | stage = stage }

-- update
type Msg
  = StageMsg Stage.Msg
  | ChangedUrl Url
  | ClickedLink Browser.UrlRequest

update : Msg -> Model -> State
update msgBox model =
  case msgBox of
    ChangedUrl url ->
      State.just model
        |> State.merge setStage StageMsg (Stage.transition url model.stage)
    StageMsg msg ->
      State.just model
        |> State.merge setStage StageMsg (Stage.update model.session msg model.stage)
    _ ->
      State.just model

-- subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
  Stage.subscriptions model.stage
    |> Sub.map StageMsg

-- view
view : Model -> Browser.Document Msg
view model =
  { title = "Scribe"
  , body  =
    [ H.toUnstyled Theme.global
    , H.toUnstyled (Stage.view model.stage |> H.map StageMsg)
    ]
  }
