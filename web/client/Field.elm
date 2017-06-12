module Field exposing (Model, Action, init, update, view)

import Html exposing (..)
import Html.Events exposing (..)
import FieldStyles exposing (styles)
import Rules

-- model
type alias Model =
  { value: String
  , isFocused: Bool
  }

init : Model
init =
  { value = ""
  , isFocused = False
  }

-- update
type Action =
  Change String |
  Focus Bool

update : Action -> Model -> Model
update msg model =
  case msg of
    Change value ->
      { model | value = value }
    Focus isFocused ->
      { model | isFocused = isFocused }

-- view
view : (Action -> a) -> Model -> Html a
view action model =
  let
    isBlank =
      String.isEmpty model.value
    when condition value =
      if condition then Just value else Nothing
    placeholderStyles =
      Rules.merge
        [ Just styles.placeholder
        , when (not isBlank) styles.hidden
        ]
    valueStyles =
      Rules.merge
        [ Just styles.value
        , when isBlank styles.hidden
        ]
    caretStyles =
      Rules.merge
        [ Just styles.caret
        , when model.isFocused styles.animating
        ]
  in
    div [ styles.wrapper ]
      [ input
        [ styles.shadowInput
        , onInput (action << Change)
        , onFocus (action (Focus True))
        , onBlur (action (Focus False))
        ] []
      , div [ styles.input ]
        [ span valueStyles [ text model.value ]
        , span [ styles.outerCaret ]
          [ div caretStyles [] ]
        , span placeholderStyles [ text "150 Characters" ]
        ]
      ]
