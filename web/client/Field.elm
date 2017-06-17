module Field exposing (Model, Action, init, update, view)

import Html exposing (..)
import Html.Events exposing (..)
import FieldStyles exposing (styles)

-- model
type alias Model =
  { value: String
  }

init : Model
init =
  { value = ""
  }

-- update
type Action =
  Change String

update : Action -> Model -> Model
update msg model =
  case msg of
    Change value ->
      { model | value = value }

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
        [ span (styles.placeholder :: hiddenWhen (not isBlank))
          [ text (toString characterLimit ++ " Characters") ]
        , span (styles.shadowText :: hiddenWhen isBlank)
          [ text model.value ]
        , span (styles.countAnchor :: hiddenWhen isBlank)
          [ div (styles.count :: hiddenWhen isBlank)
            [ text (toString charactersLeft) ]
          ]
        ]
      , textarea [ styles.input, onInput (action << Change) ] []
      ]
