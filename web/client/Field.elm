module Field exposing (Model, Action, init, update, view)

import Dom.Size exposing (Boundary(..))
import FieldStyles exposing (Classes(..), styles, inline, lineHeight)
import Html exposing (..)
import Html.Attributes exposing (id, autofocus, maxlength)
import Html.Events exposing (onWithOptions, onInput, keyCode)
import Json.Decode as Decode
import Json.Decode.Extra as DecodeExt
import Keys
import Task

-- constants
characterLimit : Int
characterLimit = 150

-- model
type alias Model =
  { value: String
  , height: Float
  }

init : (Model, Cmd Action)
init =
  { value = ""
  , height = lineHeight * 2
  }
  ! [calculateHeight ""]

-- update
type Action
  = None
  | Change String
  | Resize Float

update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    None ->
      (model, Cmd.none)
    Change value ->
      ({ model | value = value }, calculateHeight value)
    Resize height ->
      ({ model | height = lineHeight + height }, Cmd.none)

-- commands
calculateHeight : String -> Cmd Action
calculateHeight value =
  let
    isEmpty =
      String.isEmpty value
    calculateCommand =
      Dom.Size.height VisibleContentWithBordersAndMargins "shadow-input"
        |> Task.attempt
          (\result ->
            case result of
              Ok height -> Resize height
              Err _ -> Resize 0.0)
  in
    if isEmpty then Cmd.none else calculateCommand

-- events

-- there's no simple way to selectively `preventDefault` in event handlers right
-- now. solution lifted heavily from this issue:
-- https://github.com/elm-lang/virtual-dom/issues/18
filterIllegalKeys : String -> (Action -> a) -> Attribute a
filterIllegalKeys currentText action =
  let
    options =
      { stopPropagation = False, preventDefault = True }
    wrapKey code =
      if isIllegal code then Ok code else Err "ignored input"
    isIllegal code =
      code == Keys.space && String.endsWith " " currentText ||
      code == Keys.newline
  in
    onWithOptions "keypress" options
      (keyCode
        |> Decode.andThen (wrapKey >> DecodeExt.fromResult)
        |> Decode.map (\_ -> action None))

-- view
{ class, classes } = styles

view : (Action -> a) -> Model -> Html a
view action model =
  let
    charactersLeft =
      characterLimit - (String.length model.value)
    isBlank =
      String.isEmpty model.value
    shadowInputClasses =
      classes
        [ (Placeholder, True)
        , (Hidden, not isBlank)
        ]
  in
    div [ class Wrapper ]
      [ div [ id "shadow-input", class ShadowInput ]
        [ span [ shadowInputClasses ]
          [ text (toString characterLimit ++ " Characters") ]
        , span [ classes [(Hidden, isBlank)] ]
          [ span [ class ShadowText ]
            [ text model.value ]
          , span [ class CountAnchor ]
            [ span [ class Count ]
              [ text (toString charactersLeft) ]
            ]
          ]
        ]
      , textarea
        [ class Input
        , inline.height model.height
        , autofocus True
        , maxlength characterLimit
        , filterIllegalKeys model.value action
        , onInput (action << Change)
        ]
        [ text model.value ]
      ]
