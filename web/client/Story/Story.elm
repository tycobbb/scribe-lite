module Story.Story exposing (State, Model, Action, view, update, init)

import Html exposing (..)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onInput, onSubmit)
import Json.Encode as JE
import Json.Decode as JD exposing (field)
import Phoenix.Channel as Channel
import Phoenix.Push as Push
import Story.Styles exposing (Classes(..), styles)
import Story.Line.Line as Line
import Socket.Event

-- constants
room : String
room = "story:unified"

-- state
type alias State =
  (Model, Cmd Action, Socket.Event.Event Action)

type alias Model =
  { line : Line.Model
  , prompt : String
  , author : String
  , email : String
  , name : String
  }

init : State
init =
  let
    (line, lineCmd) = Line.init
  in
    ( { line = line
      , prompt = ""
      , author = ""
      , email = ""
      , name = ""
      }
    , Cmd.map LineAction lineCmd
    , joinChannel
    )

joinChannel : Socket.Event.Event Action
joinChannel =
  Channel.init room
    |> Channel.onJoin JoinStory
    |> Socket.Event.join

-- update
type Action
  = LineAction Line.Action
  | ChangeEmail String
  | ChangeName String
  | JoinStory JE.Value
  | SubmitLine

update : Action -> Model -> State
update action model =
  case action of
    LineAction lineAction ->
      Line.update lineAction model.line
        |> setLine model
    ChangeEmail email ->
      { model | email = email }
        |> toState
    ChangeName name ->
      { model | name = name }
        |> toState
    JoinStory raw ->
      decodePrompt raw
        |> setPrompt model
    SubmitLine ->
      ( model
      , Cmd.none
      , submitLine model
      )

setLine : Model -> (Line.Model, Cmd Line.Action) -> State
setLine model (field, cmd) =
  ( { model | line = field }
  , Cmd.map LineAction cmd
  , Socket.Event.none
  )

setPrompt : Model -> Result e StoryPrompt -> State
setPrompt model result =
  result
    |> Result.map (\{prompt, author} -> { model | prompt = prompt, author = author })
    |> Result.withDefault model
    |> toState

toState : Model -> State
toState model =
  (model, Cmd.none, Socket.Event.none)

-- request data
type alias StoryPrompt =
  { prompt : String
  , author : String
  }

decodePrompt : JD.Value -> Result String StoryPrompt
decodePrompt =
  JD.decodeValue
    (JD.map2 StoryPrompt
      (field "prompt" JD.string)
      (field "author" JD.string))

submitLine : Model -> Socket.Event.Event Action
submitLine model =
  Push.init "new:line" room
    |> Push.withPayload (encodeLinePayload model)
    |> Socket.Event.push

encodeLinePayload : Model -> JE.Value
encodeLinePayload model =
  JE.object
    [ ("line", JE.string model.line.value)
    , ("email", JE.string model.email)
    , ("name", JE.string model.name)
    ]

-- view
{ class, classes } = styles

view : Model -> Html Action
view model =
  div [ class Container ]
    [ div [ class Header ]
      [ text "Friday May 24 (2017)" ]
    , content model
      [ p [ class Author ]
        [ text model.author ]
      , p [ class Prompt ]
        [ text model.prompt ]
      , Line.view model.line
          |> Html.map LineAction
      , emailField model
      , submitRow model
        [ nameField model
        , submitButton
        ]
      ]
    ]

content : Model -> List (Html Action) -> Html Action
content model =
  form
    [ Content |> showsAfter [model.prompt]
    , onSubmit SubmitLine
    ]

emailField : Model -> Html Action
emailField model =
  input
    [ EmailField |> showsAfter [model.line.value]
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
  div [ SubmitRow |> showsAfter [model.line.value, model.email] ]

submitButton : Html Action
submitButton =
  button [ class SubmitButton ]
    [ span []
      [ text "Submit"
      , div [ class Chevron ] []
      ]
    ]

showsAfter : List String -> Classes -> Attribute m
showsAfter values klass =
  classes
    [ (klass, True)
    , (Visible, List.all (not << String.isEmpty) values)
    ]
