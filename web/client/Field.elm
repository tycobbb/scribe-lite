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
    isBlank =
      String.isEmpty model.value
    hideWhen condition =
      if condition then [ styles.hidden ] else []
  in
    div [ styles.wrapper ]
      [ div [ styles.shadowInput ]
        [ span (styles.placeholder :: hideWhen (not isBlank))
          [ text "150 Characters" ]
        , span (styles.shadowText :: hideWhen isBlank)
          [ text model.value ]
        , span (styles.count :: hideWhen isBlank)
          [ text (model.value |> String.length |> toString) ]
        ]
      , textarea [ styles.input, onInput (action << Change) ] []
      ]
