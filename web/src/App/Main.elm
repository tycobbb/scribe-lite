module Main exposing (main)

import Html.Styled as H exposing (Html)
import Html.Styled.Attributes exposing (css, style)
import Html.Styled.Keyed as HK
import Router.Route as Route
import Router.Scene as Scene
import Browser
import Browser.Navigation as Nav
import Url exposing (Url)
import Socket exposing (Socket)
import Css exposing (..)
import Helpers exposing (..)

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
  ( Model
  , Cmd Msg
  )

type alias Model =
  { stage  : Stage
  , socket : Socket Msg
  , key    : Nav.Key
  }

init _ url key =
  withoutCmd (initModel key)
    |> setScene Active (initScene url 0)

initModel : Nav.Key -> Model
initModel key =
  { stage  = Blank
  , socket = initSocket
  , key    = key
  }

-- stage
type Stage
  = Active IndexedScene
  | Transition Bool IndexedScenes
  | Blank

type alias IndexedScenes =
  { scene : IndexedScene
  , nextScene : IndexedScene
  }

type alias IndexedScene =
  Indexed Scene.Model

-- update
type Msg
  = SceneMsg (Indexed Scene.Msg)
  | SocketMsg (Socket.Msg Msg)
  | StartTransition
  | EndTransition
  | ChangedUrl Url
  | ClickedLink Browser.UrlRequest

update : Msg -> Model -> State
update msgBox model =
  case (msgBox, model.stage) of
    ( ChangedUrl location, Active scene ) ->
      withoutCmd model
        |> setScene (stageFrom scene (Transition False)) (initScene location (scene.index + 1))
        |> joinCmd (async StartTransition)
    ( SocketMsg msg, _ ) ->
      withoutCmd model
        -- |> setSocket (Socket.update msg model.socket)
    ( SceneMsg msg, Active scene ) ->
      withoutCmd model
        |> updateScene Active msg scene
    ( SceneMsg msg, Transition isActive scenes ) ->
      withoutCmd model
        |> updateScenes (Transition isActive) msg scenes
    ( StartTransition, Transition False scenes ) ->
      { model | stage = Transition True scenes }
        |> withCmd (delay duration EndTransition)
    ( EndTransition, Transition True scenes ) ->
      { model | stage = Active scenes.nextScene }
        |> withoutCmd
    _ ->
      withoutCmd model

-- subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
  -- Socket.listen model.socket SocketMsg

-- view
view : Model -> Browser.Document Msg
view model =
  { title = "Scribe"
  , body  = [ H.toUnstyled (viewStage model) ]
  }

viewStage : Model -> Html Msg
viewStage { stage } =
  case stage of
    Active scene ->
      viewStageKeyed scene
        [ viewSceneWithKey scene Nothing
        ]
    Transition False { scene, nextScene } ->
      viewStageKeyed scene
        [ viewSceneWithKey scene Nothing
        , viewSceneWithKey nextScene (Just sceneInB)
        ]
    Transition True { scene, nextScene } ->
      viewStageKeyed nextScene
        [ viewSceneWithKey scene (Just sceneOutB)
        , viewSceneWithKey nextScene Nothing
        ]
    Blank ->
      stageS []
        [ ( "blank", H.text "" ) ]

viewStageKeyed : IndexedScene -> List ( String, Html Msg ) -> Html Msg
viewStageKeyed { item } =
  stageS
    [ backgroundColorI item.color ]

viewScene : IndexedScene -> Maybe Style -> Html Msg
viewScene scene animations =
  let
    styles =
      List.filterMap identity [ animations ]
  in
    sceneS [ css styles ]
      [ Scene.view scene.item
          |> H.map (indexable SceneMsg scene.index)
      ]

viewSceneWithKey : IndexedScene -> Maybe Style -> ( String, Html Msg )
viewSceneWithKey scene animations =
  ( "scene-" ++ String.fromInt scene.index
  , viewScene scene animations
  )

-- scenes
initScene : Url -> Int -> Change IndexedScene Scene.Msg
initScene location index =
  Scene.init (Route.toRoute location)
    |> withIndex index

setScene : (IndexedScene -> Stage) -> Change IndexedScene Scene.Msg -> State -> State
setScene asStage sceneState ( model, cmd ) =
  { model | stage = asStage sceneState.model }
    |> withCmd cmd
    |> joinEffects (mapEffects (asSceneMsg sceneState.model.index) sceneState.effects)

updateScenes : (IndexedScenes -> Stage) -> Indexed Scene.Msg -> IndexedScenes -> State -> State
updateScenes asStage msg { scene, nextScene } =
  if msg.index == scene.index then
    updateScene (stageTo nextScene asStage) msg scene
  else if msg.index == nextScene.index then
    updateScene (stageFrom scene asStage) msg nextScene
  else
    identity

updateScene : (IndexedScene -> Stage) -> Indexed Scene.Msg -> IndexedScene -> State -> State
updateScene asStage msg scene =
  Scene.update msg.item scene.item
    |> withIndex scene.index
    |> setScene asStage

joinEffects : Effects Msg -> State -> State
joinEffects ( cmd, event ) =
  joinCmd cmd
    >> sendEvent event

asSceneMsg : Int -> Scene.Msg -> Msg
asSceneMsg =
  indexable SceneMsg

-- socket
initSocket : Socket msg
initSocket =
  Socket.init
  -- Socket.init serverUrl
  --   |> Socket.withDebug

setSocket : ( Socket Msg, Cmd (Socket.Msg Msg) ) -> State -> State
setSocket ( socket, socketCmd ) ( model, cmd ) =
  { model | socket = socket }
    |> withCmd cmd
    |> joinCmd (Cmd.map SocketMsg socketCmd)

sendEvent : Socket.Event Msg -> State -> State
sendEvent _ state  =
  state
  -- let
  --   (socket, socketCmd) =
  --     Socket.Event.send model.socket event
  -- in
  --   { model | socket = socket }
  --     |> withCmd cmd
  --     |> joinCmd (Cmd.map SocketMsg socketCmd)

-- transitions
stageFrom : IndexedScene -> (IndexedScenes -> Stage) -> IndexedScene -> Stage
stageFrom source asStage =
  (IndexedScenes source) >> asStage

stageTo : IndexedScene -> (IndexedScenes -> Stage) -> IndexedScene -> Stage
stageTo destination asStage =
  (\source -> IndexedScenes source destination) >> asStage

-- styles
duration    : number
duration    = 300

translation : number
translation = 50

stageS attrs =
  HK.node "div"
    (attrs ++
    [ css
      [ position relative
      , transitionB ["background-color"]
      ]
    ]
    )

sceneS =
  H.styled H.section
    [ transitionB ["top", "opacity"]
    , position absolute
    , top (px 0)
    , left (px 0)
    , right (px 0)
    ]

sceneInB : Style
sceneInB =
  Css.batch
    [ top (px translation)
    , opacity (int 0)
    ]

sceneOutB : Style
sceneOutB =
  Css.batch
    [ top (px -translation)
    , opacity (int 0)
    ]

transitionB : List String -> Style
transitionB attributes =
  let
    durationPart =
      " " ++ String.fromInt duration ++ "ms"
    toTransition attribute =
      attribute ++ durationPart
  in
    attributes
      |> List.map toTransition >> String.join ", "
      |> property "transition"

backgroundColorI : Color -> H.Attribute Msg
backgroundColorI color =
  style "backgroundColor" (String.fromInt color.red)
