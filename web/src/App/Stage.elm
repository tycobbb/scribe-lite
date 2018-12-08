module Stage exposing (..)

import Css exposing (..)
import Css.Global as CG
import Html.Styled as H exposing (Html)
import Html.Styled.Attributes exposing (css, style)
import Html.Styled.Keyed as HK
import Process
import Task
import Url exposing (Url)

import Route
import Scenes.Scene as Scene
import State
import Session exposing (Session)

-- state
type alias State =
  State.Base Model Msg

type Model
  = Active (Indexed Scene.Model)
  | Transition Bool ((Indexed Scene.Model), (Indexed Scene.Model))
  | Blank

init : Url -> State
init url =
  initScene url 0
    |> State.map Active SceneMsg

blank : Model
blank =
  Blank

-- transition
transition : Url -> Model -> State
transition url model =
  case model of
    Active exiting ->
      initScene url (exiting.index + 1)
        |> State.map ((Tuple.pair exiting) >> (Transition False)) SceneMsg
        |> State.joinCmd (async StartTransition)
    _ ->
      State.just model

-- update
type Msg
  = SceneMsg (Indexed Scene.Msg)
  | StartTransition
  | EndTransition

update : Session -> Msg -> Model -> State
update session msgBox model =
  case (msgBox, model) of
    ( SceneMsg msg, Active scene ) ->
      scene
        |> updateScene session msg
        |> State.map Active SceneMsg
    ( SceneMsg msg, Transition isActive scenes ) ->
      scenes
        |> updateScenes session msg
        |> State.map (Transition isActive) SceneMsg
    ( StartTransition, Transition False scenes ) ->
      Transition True scenes
        |> State.withCmd (delay duration EndTransition)
    ( EndTransition, Transition True (_, entering) ) ->
      State.just (Active entering)
    _ ->
      State.just model

-- subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
  let
    fromScene { index, item } =
      Scene.subscriptions item
        |> Sub.map (indexedT SceneMsg index)
  in
    case model of
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
view : Model -> Html Msg
view model =
  case model of
    Active scene ->
      viewStage scene
        [ viewScene scene Nothing
        ]
    Transition False (exiting, entering) ->
      viewStage exiting
        [ viewScene exiting Nothing
        , viewScene entering (Just sceneInB)
        ]
    Transition True (exiting, entering) ->
      viewStage entering
        [ viewScene exiting (Just sceneOutB)
        , viewScene entering Nothing
        ]
    Blank ->
      stageS []
        [ ( "blank", H.text "" ) ]

viewStage : Indexed Scene.Model -> List ( String, Html Msg ) -> Html Msg
viewStage { item } children =
  stageS []
    (( "body", bodyG item.color ) :: children)

viewScene : Indexed Scene.Model -> Maybe Style -> ( String, Html Msg )
viewScene scene animations =
  let
    key =
      "scene-" ++ String.fromInt scene.index
    styles =
      List.filterMap identity [ animations ]
  in
    ( key
    , sceneS [ css styles ]
      [ Scene.view scene.item
        |> H.map (indexedT SceneMsg scene.index)
      ]
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

updateScenes : Session -> Indexed Scene.Msg -> (Indexed Scene.Model, Indexed Scene.Model) -> State.Base (Indexed Scene.Model, Indexed Scene.Model) (Indexed Scene.Msg)
updateScenes session msg scenes =
  let
    updateOne =
      updateScene session msg
    unzip ((ll, lr), (rl, rr)) =
      ((ll, rl), (lr, rr))
    batchCmds (l, r) =
      Cmd.batch [l, r]
  in
    scenes
      |> Tuple.mapBoth updateOne updateOne
      |> unzip
      |> Tuple.mapSecond batchCmds

updateScene : Session -> Indexed Scene.Msg -> Indexed Scene.Model -> State.Base (Indexed Scene.Model) (Indexed Scene.Msg)
updateScene session msg model =
  let
    updateOne =
      indexedFn (Scene.update session)
    indexed =
      Indexed model.index
  in
    model
      |> updateOne msg
      |> Maybe.withDefault (State.just model.item)
      |> State.map indexed indexed

-- indexed
type alias Indexed a =
  { index : Int
  , item  : a
  }

indexedFn : (a -> b -> c) -> Indexed a -> Indexed b -> Maybe c
indexedFn fn first second =
  if first.index /= second.index then
    Nothing
  else
    Just (fn first.item second.item)

indexedT : (Indexed a -> b) -> Int -> a -> b
indexedT other index =
  (Indexed index) >> other

-- timers
async : m -> Cmd m
async =
  delay 17

delay : Float -> m -> Cmd m
delay time msg =
  Process.sleep time
    |> Task.perform (always msg)

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
