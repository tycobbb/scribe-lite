module Main exposing (main)

import Html exposing (..)
import MainStyles exposing (styles)
import Field

main : Program Never Model Action
main =
  beginnerProgram { model = init, view = view , update = update }

-- model
type alias Model =
  { field: Field.Model
  }

init : Model
init =
  { field = Field.init
  }

-- update
type Action =
  FieldAction Field.Action

update : Action -> Model -> Model
update action model =
  case action of
    FieldAction action ->
      { model | field = Field.update action model.field }

-- view
view : Model -> Html Action
view model =
  let
    date =
      "Friday May 24 (2017)"
  in
    div [ styles.container ]
      [ div [ styles.header ]
        [ text date ]
      , div [ styles.content ]
        [ p [ styles.author ] [ text "Gob Bluth" ]
        , p [ styles.prompt ]
          [ text "When the tiny dumpling decided to jump across the river, it let out a sigh." ]
        , Field.view FieldAction model.field
        ]
      ]
