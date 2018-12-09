module Scenes.Story.Line exposing (State, Model, Msg, init, update, view)

import Browser.Dom as Dom
import Css exposing (..)
import Dict exposing (Dict)
import Html.Styled as H exposing (Html)
import Html.Styled.Attributes exposing (id, value, placeholder, autofocus, maxlength, style)
import Html.Styled.Events exposing (onInput, preventDefaultOn, keyCode)
import Json.Decode as JD
import Json.Decode.Extra as DecodeExt
import Task

import State
import Styles.Colors as Colors
import Styles.Fonts as Fonts
import Styles.Mixins as Mixins

-- constants
characterLimit : Int
characterLimit = 150

lineHeight : Float
lineHeight = 81

shadowInputId : String
shadowInputId = "shadow-input"

-- model
type alias State =
  State.Pair Model Msg

type alias Model =
  { value  : String
  , height : Float
  }

init : State
init =
  initModel
    |> State.withCmd (calculateHeight "")

initModel : Model
initModel =
  { value  = ""
  , height = lineHeight * 2
  }

-- update
type Msg
  = Change String
  | Resize Float
  | Ignored

update : Msg -> Model -> State
update msg model =
  case msg of
    Change value ->
      { model | value = value }
        |> State.withCmd (calculateHeight value)
    Resize height ->
      { model | height = lineHeight + height }
        |> State.withoutCmd
    Ignored ->
      State.just model

-- commands
calculateHeight : String -> Cmd Msg
calculateHeight value =
  if String.isEmpty value
    then Cmd.none
    else Cmd.map Resize checkFieldHeight

checkFieldHeight : Cmd Float
checkFieldHeight =
  Dom.getElement shadowInputId
    |> Task.attempt
      (\result ->
        case result of
          Ok  rect -> rect.element.height
          Err _    -> 0.0)

-- events
space   : Int
space   = Char.toCode ' '

newline : Int
newline = Char.toCode '\r'

onKeypress : String -> H.Attribute Msg
onKeypress currentText =
  let
    isIllegal code =
      code == space && String.endsWith " " currentText ||
      code == newline
  in
    preventDefaultOn "keypress"
      (JD.field "keyCode" JD.int
        |> JD.map isIllegal
        |> JD.map (Tuple.pair Ignored))

-- view
view : Model -> Html Msg
view model =
  containerS []
    [ viewShadowField model
    , viewField model
    ]

viewShadowField : Model -> Html Msg
viewShadowField model =
  if String.isEmpty model.value then
    H.text ""
  else
    shadowInputS [ id shadowInputId ]
      [ shadowFieldS []
        [ shadowTextS []
          [ H.text model.value
          ]
        , viewFieldCount model
        ]
      ]

viewField : Model -> Html Msg
viewField model =
  let
    placeholderText =
      String.fromInt characterLimit ++ " Characters"
  in
    fieldS
      [ fieldHeightI model.height
      , autofocus True
      , maxlength characterLimit
      , onKeypress model.value
      , onInput Change
      , placeholder placeholderText
      , value model.value
      ] []

viewFieldCount : Model -> Html Msg
viewFieldCount model =
  let
    charactersLeft =
      characterLimit - (String.length model.value)
    charactersText =
      "  " ++ String.fromInt charactersLeft
  in
    fieldCountS []
      [ H.text charactersText ]

-- styles
containerS : List (H.Attribute m) -> List (Html m) -> Html m
containerS =
  H.styled H.div
    [ displayFlex
    , flexDirection column
    , position relative
    , marginBottom (px -lineHeight)
    , Fonts.lg
    ]

shadowInputS : List (H.Attribute m) -> List (Html m) -> Html m
shadowInputS =
  H.styled H.div
    [ position absolute
    , top (px 0)
    , left (px 0)
    , right (px 0)
    , property "pointer-events" "none"
    ]

shadowFieldS : List (H.Attribute m) -> List (Html m) -> Html m
shadowFieldS =
  H.styled H.span
    [ fieldB
    ]

shadowTextS : List (H.Attribute m) -> List (Html m) -> Html m
shadowTextS =
  H.styled H.span
    [ color transparent
    ]

fieldS : List (H.Attribute m) -> List (Html m) -> Html m
fieldS =
  H.styled H.textarea
    [ fieldB
    , Mixins.textFieldB
    , resize none
    ]

fieldCountS : List (H.Attribute m) -> List (Html m) -> Html m
fieldCountS =
  H.styled H.span
    [ color Colors.gray0
    ]

fieldB : Style
fieldB =
  Css.batch
    [ overflow auto
    , property "word-wrap" "break-word"
    , property "white-space" "pre-wrap"
    ]

fieldHeightI : Float -> H.Attribute Msg
fieldHeightI height =
  style "height" (String.fromFloat height ++ "px")
