module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import MainStyles exposing (Classes(..), styles)
import LineField.Element as LineField

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
  { lineField: LineField.Model
  , email: String
  , name: String
  }

merge : (a -> b) -> (a, Cmd LineField.Action) -> (b, Cmd Action)
merge combiner (lineField, cmd) =
  (combiner lineField, Cmd.map (\a -> LineFieldAction a) cmd)

init : (Model, Cmd Action)
init =
  merge (\f ->
    { lineField = f
    , email = ""
    , name = "" }) LineField.init

-- update
type Action
  = LineFieldAction LineField.Action
  | ChangeEmail String
  | ChangeName String

update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    LineFieldAction action ->
      merge (\f -> { model | lineField = f }) (LineField.update action model.lineField)
    ChangeEmail email ->
      ({ model | email = email }, Cmd.none)
    ChangeName name ->
      ({ model | name = name }, Cmd.none)

-- view
{ class, classes } = styles

view : Model -> Html Action
view model =
  let
    date =
      "Friday May 24 (2017)"
    submitRowClasses =
      classes
        [ (SubmitRow, True)
        , (Visible, (not << String.isEmpty) model.email)
        ]
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
          , LineField.view LineFieldAction model.lineField
          , input
            [ class EmailField
            , onInput ChangeEmail
            , placeholder "E-mail Address"
            ] []
          , div [ submitRowClasses ]
            [ input
              [ class NameField
              , onInput ChangeName
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
