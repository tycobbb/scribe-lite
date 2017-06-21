module Field exposing (Model, Action, init, update, view)

import Dom.Size exposing (Boundary(..))
import FieldStyles exposing (styles)
import Html exposing (..)
import Html.Attributes exposing (id, maxlength)
import Html.Events exposing (onWithOptions, onInput, keyCode)
import Json.Decode as Decode
import Json.Decode.Extra as DecodeExt
import Keys
import Task

-- constants
lineHeight : Float
lineHeight = 48

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
    elementId =
      if String.isEmpty value then "placeholder" else "shadow-input"
  in
    Dom.Size.height VisibleContentWithBordersAndMargins elementId
      |> Task.attempt
        (\result ->
          case result of
            Ok height -> Resize height
            Err _ -> Resize 0.0)

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
view : (Action -> a) -> Model -> Html a
view action model =
  let
    charactersLeft =
      characterLimit - (String.length model.value)
    isBlank =
      String.isEmpty model.value
    hiddenWhen condition =
      if condition then [ styles.hidden ] else []
  in
    div [ styles.wrapper ]
      [ div [ styles.shadowInput ]
        [ span (id "placeholder" :: styles.placeholder :: hiddenWhen (not isBlank))
          [ text (toString characterLimit ++ " Characters") ]
        , span (id "shadow-input" :: styles.shadowText :: hiddenWhen isBlank)
          [ text model.value ]
        , span (styles.countAnchor :: hiddenWhen isBlank)
          [ div (styles.count :: hiddenWhen isBlank)
            [ text (toString charactersLeft) ]
          ]
        ]
      , textarea
        [ styles.input
        , styles.height model.height
        , maxlength characterLimit
        , filterIllegalKeys model.value action
        , onInput (action << Change)
        ]
        [ text model.value ]
      ]
