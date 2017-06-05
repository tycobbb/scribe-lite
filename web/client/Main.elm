module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import MainStyles exposing (styles)

main : Program Never Model Msg
main =
  beginnerProgram { model = Model "", view = view , update = update }

-- model
type alias Model =
  { value: String
  }

init : Model
init =
  Model ""

-- update
type Msg =
  Change String

update : Msg -> Model -> Model
update msg model =
  case msg of
    Change value ->
      Model value

-- view
view : Model -> Html Msg
view model =
  div [ styles.container ]
    [ div [ styles.field ]
      [ p [ styles.prompt ]
        [ text "It was a dark and stormy night, somewhere." ]
      , input [ styles.input, placeholder "Whatcha think...", onInput Change ]
        []
      ]
    ]
