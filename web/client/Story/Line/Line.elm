module Story.Line.Line exposing (Model, Msg, init, update, view)

import Dom.Size exposing (Boundary(..))
import Html exposing (..)
import Html.Attributes exposing (id, placeholder, autofocus, maxlength)
import Html.Events exposing (onWithOptions, onInput, keyCode)
import Json.Decode as Decode
import Json.Decode.Extra as DecodeExt
import Task
import Story.Line.Styles exposing (Classes(..), styles, inline, lineHeight)
import Story.Line.Keys as Keys

-- constants
characterLimit : Int
characterLimit = 150

shadowInputId : String
shadowInputId = "shadow-input"

-- model
type alias Model =
  { value: String
  , height: Float
  }

init : (Model, Cmd Msg)
init =
  ( { value = ""
    , height = lineHeight * 2
    }
  , calculateHeight ""
  )

-- update
type Msg
  = None
  | Change String
  | Resize Float

update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    None ->
      (model, Cmd.none)
    Change value ->
      ({ model | value = value }, calculateHeight value)
    Resize height ->
      ({ model | height = lineHeight + height }, Cmd.none)

-- commands
calculateHeight : String -> Cmd Msg
calculateHeight value =
  if String.isEmpty value
    then Cmd.none
    else Cmd.map Resize checkFieldHeight

checkFieldHeight : Cmd Float
checkFieldHeight =
  Dom.Size.height VisibleContentWithBordersAndMargins shadowInputId
    |> Task.attempt
      (\result ->
        case result of
          Ok height -> height
          Err _ -> 0.0)

-- events

-- there's no simple way to selectively `preventDefault` in event handlers right
-- now. solution lifted heavily from this issue:
-- https://github.com/elm-lang/virtual-dom/issues/18
filterIllegalKeys : String -> Attribute Msg
filterIllegalKeys currentText =
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
        |> Decode.map (\_ -> None))

-- view
{ class, classes } = styles

view : Model -> Html Msg
view model =
  div [ class Container ]
    [ div [ id shadowInputId, class ShadowInput ]
      [ shadowField model
      ]
    , field model
    ]

shadowField : Model -> Html Msg
shadowField model =
  let
    charactersLeft =
      characterLimit - (String.length model.value)
  in
    if String.isEmpty model.value then
      text ""
    else
      span [ class ShadowField ]
        [ span [ class ShadowText ]
          [ text model.value ]
        , span [ class Count ]
          [ text ("  " ++ toString charactersLeft) ]
        ]

field : Model -> Html Msg
field model =
  textarea
    [ class Input
    , inline.height model.height
    , autofocus True
    , maxlength characterLimit
    , filterIllegalKeys model.value
    , onInput Change
    , placeholder (toString characterLimit ++ " Characters")
    ]
    [ text model.value ]
