module Scenes.Story.Line exposing (State, Model, Msg, init, update, view)

import Html.Styled as H exposing (Html)
import Html.Styled.Attributes exposing (id, value, placeholder, autofocus, maxlength, style)
import Html.Styled.Events exposing (onInput, preventDefaultOn, keyCode)
import Browser.Dom as Dom
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Decode.Extra as DecodeExt
import Task
import State
import Css exposing (..)
import Styles.Fonts as Fonts
import Styles.Colors as Colors
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
  ( Model
  , Cmd Msg
  )

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
  = None
  | Change String
  | Resize Float

update : Msg -> Model -> State
update msg model =
  case msg of
    None ->
      ( model, Cmd.none )
    Change value ->
      ( { model | value = value }, calculateHeight value )
    Resize height ->
      ( { model | height = lineHeight + height }, Cmd.none )

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

-- there's no simple way to selectively `preventDefault` in event handlers right
-- now. solution lifted heavily from this issue:
-- https://github.com/elm-lang/virtual-dom/issues/18
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
        |> JD.map (Tuple.pair None))

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
containerS =
  H.styled H.div
    [ Fonts.lg
    , position relative
    ]

shadowInputS =
  H.styled H.div
    [ position absolute
    , top (px 0)
    , left (px 0)
    , right (px 0)
    , property "pointer-events" "none"
    ]

shadowFieldS =
  H.styled H.span
    [ fieldB
    ]

shadowTextS =
  H.styled H.span
    [ color transparent
    ]

fieldS =
  H.styled H.textarea
    [ fieldB
    , resize none
    ]

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

fieldHeightI height =
  style "height" (String.fromFloat height ++ "px")
