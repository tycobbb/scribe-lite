module Compose.Compose exposing (Model, Action, view, update, init)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Compose.Styles exposing (Classes(..), styles)
import Compose.Line.Line as Line

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
    ( { line = line
      , email = ""
      , name = ""
      }
    , Cmd.map LineAction lineCmd
    )

-- update
type Action
  = LineAction Line.Action
  | ChangeEmail String
  | ChangeName String

update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    LineAction lineAction ->
      Line.update lineAction model.line
        |> setLine model
    ChangeEmail email ->
      ({ model | email = email }, Cmd.none)
    ChangeName name ->
      ({ model | name = name }, Cmd.none)

setLine : Model -> (Line.Model, Cmd Line.Action) -> (Model, Cmd Action)
setLine model (field, cmd) =
  ({ model | line = field }, Cmd.map LineAction cmd)

-- view
{ class, classes } = styles

view : Model -> Html Action
view model =
  div [ class Container ]
    [ div [ class Header ]
      [ text "Friday May 24 (2017)" ]
    , div [ class Content ]
      [ p [ class Author ]
        [ text "Gob Bluth" ]
      , p [ class Prompt ]
        [ text "When the tiny dumpling decided to jump across the river, it let out a sigh." ]
      , Line.view model.line
          |> Html.map LineAction
      , emailField model
      , submitRow model
        [ nameField model
        , submitButton
        ]
      ]
    ]

emailField : Model -> Html Action
emailField model =
  input
    [ class EmailField
    , onInput ChangeEmail
    , placeholder "E-mail Address"
    ] [ text model.email ]

nameField : Model -> Html Action
nameField model =
  input
    [ class NameField
    , onInput ChangeName
    , placeholder "Name to Display (Optional)"
    ] [ text model.name ]

submitRow : Model -> List (Html Action) -> Html Action
submitRow model =
  div
    [ classes
      [ (SubmitRow, True)
      , (Visible, (not << String.isEmpty) model.email)
      ]
    ]

submitButton : Html Action
submitButton =
  button [ class SubmitButton ]
    [ span []
      [ text "Submit"
      , div [ class Chevron ] []
      ]
    ]
