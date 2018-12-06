module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Css exposing (..)
import Css.Global as CG
import Html.Styled as H exposing (Html)
import Html.Styled.Attributes exposing (css, style)
import Html.Styled.Keyed as HK
import Json.Encode as JE
import Url exposing (Url)

import Indexed exposing (Indexed)
import Route
import Scenes.Scene as Scene
import Socket
import State
import Styles.Theme as Theme
import Session exposing (Session)
import Timers

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
  { stage      : Stage
  , sceneIndex : Int
  , session    : Session
  }

init _ url key =
  State.just (initModel key)
    |> State.merge setStage SceneMsg (initStage url)

initModel : Nav.Key -> Model
initModel key =
  { stage      = Blank
  , sceneIndex = 0
  , session    = Session key
  }

-- stage
type Stage
  = Active (Indexed Scene.Model)
  | Transition Bool ((Indexed Scene.Model), (Indexed Scene.Model))
  | Blank

initStage url =
  initScene url 0
    |> State.mapModel Active

initPreTransition url exiting =
  initScene url (exiting.index + 1)
    |> State.mapModel (Tuple.pair exiting)
    |> State.mapModel (Transition False)

initTransition scenes =
  Transition True scenes

initNewStage scene =
  Active scene

-- update
type Msg
  = SceneMsg (Indexed Scene.Msg)
  | StartTransition
  | EndTransition
  | ChangedUrl Url
  | ClickedLink Browser.UrlRequest

update : Msg -> Model -> State
update msgBox model =
  case (msgBox, model.stage) of
    ( ChangedUrl url, Active scene ) ->
      model
        |> State.withCmd (Timers.async StartTransition)
        |> State.merge setStage SceneMsg (initPreTransition url scene)
    ( SceneMsg msg, Active scene ) ->
      State.just model
        |>
          (scene
            |> uScene model.session msg
            |> State.map Active identity
            |> State.merge setStage SceneMsg)
    ( SceneMsg msg, Transition isActive scenes ) ->
      State.just model
        |>
          (scenes
            |> uScenes model.session msg
            |> State.mapModel (Transition isActive)
            |> State.merge setStage SceneMsg)
    ( StartTransition, Transition False scenes ) ->
      model
        |> setStage (initTransition scenes)
        |> State.withCmd (Timers.delay duration EndTransition)
    ( EndTransition, Transition True (_, entering) ) ->
      model
        |> setStage (initNewStage entering)
        |> State.withoutCmd
    _ ->
      State.just model

-- subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
  let
    fromScene { index, item } =
      Scene.subscriptions item
        |> Sub.map (Indexed.indexable SceneMsg index)
  in
    case model.stage of
      Active scene ->
        fromScene scene
      Transition _ (exiting, entering) ->
        Sub.batch
          [ fromScene exiting
          , fromScene entering
          ]
      _ ->
        Sub.none

-- view
view : Model -> Browser.Document Msg
view model =
  { title = "Scribe"
  , body  =
    [ H.toUnstyled Theme.global
    , H.toUnstyled (viewStage model)
    ]
  }

viewStage : Model -> Html Msg
viewStage { stage } =
  case stage of
    Active scene ->
      viewStageKeyed scene
        [ viewSceneWithKey scene Nothing
        ]
    Transition False (exiting, entering) ->
      viewStageKeyed exiting
        [ viewSceneWithKey exiting Nothing
        , viewSceneWithKey entering (Just sceneInB)
        ]
    Transition True (exiting, entering) ->
      viewStageKeyed entering
        [ viewSceneWithKey exiting (Just sceneOutB)
        , viewSceneWithKey entering Nothing
        ]
    Blank ->
      stageS []
        [ ( "blank", H.text "" ) ]

viewStageKeyed : Indexed Scene.Model -> List ( String, Html Msg ) -> Html Msg
viewStageKeyed { item } children =
  stageS []
    (( "body", bodyG item.color ) :: children)

viewScene : Indexed Scene.Model -> Maybe Style -> Html Msg
viewScene scene animations =
  let
    styles =
      List.filterMap identity [ animations ]
  in
    sceneS [ css styles ]
      [ Scene.view scene.item
          |> H.map (Indexed.indexable SceneMsg scene.index)
      ]

viewSceneWithKey : Indexed Scene.Model -> Maybe Style -> ( String, Html Msg )
viewSceneWithKey scene animations =
  ( "scene-" ++ String.fromInt scene.index
  , viewScene scene animations
  )

-- scenes
initScene : Url -> Int -> State.Base (Indexed Scene.Model) (Indexed Scene.Msg)
initScene location index =
  let
    indexed =
      Indexed index
  in
    location
      |> Route.toRoute
      |> Scene.init
      |> State.map indexed indexed

uScenes : Session -> Indexed Scene.Msg -> (Indexed Scene.Model, Indexed Scene.Model) -> State.Base (Indexed Scene.Model, Indexed Scene.Model) (Indexed Scene.Msg)
uScenes session msg scenes =
  let
    u =
      uScene session msg
    unzip ((ll, lr), (rl, rr)) =
      ((ll, rl), (lr, rr))
    toList (l, r) =
      [l, r]
  in
    scenes
      |> Tuple.mapBoth u u
      |> unzip
      |> Tuple.mapSecond (toList >> Cmd.batch)

uScene : Session -> Indexed Scene.Msg -> Indexed Scene.Model -> State.Base (Indexed Scene.Model) (Indexed Scene.Msg)
uScene session msg model =
  let
    u =
      Indexed.join (Scene.update session)
    indexed =
      Indexed model.index
  in
    model
      |> u msg
      |> Maybe.withDefault (State.just model.item)
      |> State.map indexed indexed

setStage : Stage -> Model -> Model
setStage stage model =
  { model | stage = stage }

-- styles
duration    : number
duration    = 300

translation : number
translation = 50

stageS attrs =
  HK.node "main"
    (attrs ++
      [ css
        [ position absolute
        , top (px 0)
        , bottom (px 0)
        , left (px 0)
        , right (px 0)
        ]
      ]
    )

sceneS =
  H.styled H.div
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

bodyG : Color -> Html Msg
bodyG color =
  CG.global
    [ CG.body
      [ minHeight (vh 100)
      , transitionB ["background-color"]
      , backgroundColor color
      ]
    ]
