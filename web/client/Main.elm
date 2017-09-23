module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import MainStyles exposing (Classes(..), styles)
import Field

main : Program Never Model Action
main =
  program
    { init = init
    , view = view
    , update = update
    , subscriptions = (\_ -> Sub.none)
    }

-- model
type alias Model =
  { field: Field.Model
  }

merge : (a -> b) -> (a, Cmd Field.Action) -> (b, Cmd Action)
merge combiner (field, cmd) =
  (combiner field, Cmd.map (\a -> FieldAction a) cmd)

init : (Model, Cmd Action)
init =
  merge (\f -> { field = f }) Field.init

-- update
type Action
  = FieldAction Field.Action

update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    FieldAction action ->
      merge (\f -> { model | field = f }) (Field.update action model.field)

-- view
{ class } = styles

view : Model -> Html Action
view model =
  let
    date =
      "Friday May 24 (2017)"
  in
    div [ class Container ]
      [ div [ class Header ]
        [ text date ]
      , div [ class Content ]
        [ div [ class Text ]
          [ p [ class Author ]
            [ text "Gob Bluth" ]
          , p [ class Prompt ]
            [ text "When the tiny dumpling decided to jump across the river, it let out a sigh." ]
          , Field.view FieldAction model.field
          , input
            [ class EmailField
            , placeholder "E-mail Address (Optional)"
            ] []
          , div [ class Row ]
            [ input
              [ class NameField
              , placeholder "Name to Display (Optional)"
              ] []
            , button [ class SubmitButton ]
              [ span []
                [ text "Submit"
                , div [ class Chevron ] []
                ]
              ]
            ]
          ]
        ]
      ]
