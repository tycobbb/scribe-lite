module Field exposing (Model, Action, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (id, maxlength)
import Html.Events exposing (onInput)
import FieldStyles exposing (styles)
import Dom.Size exposing (Boundary(..))
import Task
import Basics exposing (Never)

-- model
type alias Model =
  { value: String
  , height: Float
  }

init : (Model, Cmd Action)
init =
  { value = ""
  , height = 0.0
  }
  ! [calculateHeight ""]

-- update
type Action
  = Change String
  | Resize Float

update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    Change value ->
      ({ model | value = value }, calculateHeight value)
    Resize height ->
      ({ model | height = height }, Cmd.none)

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

-- view
view : (Action -> a) -> Model -> Html a
view action model =
  let
    characterLimit =
      150
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
        , onInput (action << Change)
        ]
        [ text model.value ]
      ]
