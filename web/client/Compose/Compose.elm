module Compose.Compose exposing (Model, Action, view, update, init)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Compose.Styles exposing (Classes(..), styles)
import Compose.Line.Line as Line
import Helpers exposing (updateField)

-- model
type alias Model =
  { line : Line.Model
  , email : String
  , name : String
  }

init : (Model, Cmd Action)
init =
  let
    (line, lineCmd) = Line.init
  in
    { line = line
    , email = ""
    , name = ""
    }
    ! [ Cmd.map LineAction lineCmd ]

-- update
type Action
  = LineAction Line.Action
  | ChangeEmail String
  | ChangeName String

update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    LineAction lineAction ->
      updateLine model (Line.update lineAction model.line)
    ChangeEmail email ->
      ({ model | email = email }, Cmd.none)
    ChangeName name ->
      ({ model | name = name }, Cmd.none)

updateLine : Model -> (Line.Model, Cmd Line.Action) -> (Model, Cmd Action)
updateLine =
  updateField (\model line -> { model | line = line }) LineAction

-- view
{ class, classes } = styles

view : (Action -> a) -> Model -> Html a
view action model =
  div [ class Container ]
    [ div [ class Header ]
      [ text "Friday May 24 (2017)" ]
    , div [ class Content ]
      [ p [ class Author ]
        [ text "Gob Bluth" ]
      , p [ class Prompt ]
        [ text "When the tiny dumpling decided to jump across the river, it let out a sigh." ]
      , Line.view (action << LineAction) model.line
      , emailField action model
      , submitRow model
        [ nameField action model
        , submitButton
        ]
      ]
    ]

emailField : (Action -> a) -> Model -> Html a
emailField action model =
  input
    [ class EmailField
    , onInput (action << ChangeEmail)
    , placeholder "E-mail Address"
    ] [ text model.email ]

nameField : (Action -> a) -> Model -> Html a
nameField action model =
  input
    [ class NameField
    , onInput (action << ChangeName)
    , placeholder "Name to Display (Optional)"
    ] [ text model.name ]

submitRow : Model -> List (Html a) -> Html a
submitRow model =
  div
    [ classes
      [ (SubmitRow, True)
      , (Visible, (not << String.isEmpty) model.email)
      ]
    ]

submitButton : Html a
submitButton =
  button [ class SubmitButton ]
    [ span []
      [ text "Submit"
      , div [ class Chevron ] []
      ]
    ]
