module Story.Story exposing (State, Model, Msg, view, update, init)

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
  (Model, Cmd Msg, Socket.Event.Event Msg)

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
    , Cmd.map LineMsg lineCmd
    , joinChannel
    )

joinChannel : Socket.Event.Event Msg
joinChannel =
  Channel.init room
    |> Channel.onJoin JoinStory
    |> Socket.Event.join

-- update
type Msg
  = LineMsg Line.Msg
  | ChangeEmail String
  | ChangeName String
  | JoinStory JE.Value
  | SubmitLine

update : Msg -> Model -> State
update action model = case action of
  LineMsg lineMsg ->
    Line.update lineMsg model.line
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

setLine : Model -> (Line.Model, Cmd Line.Msg) -> State
setLine model (field, cmd) =
  ( { model | line = field }
  , Cmd.map LineMsg cmd
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

submitLine : Model -> Socket.Event.Event Msg
submitLine model =
  Push.init "add:line" room
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

view : Model -> Html Msg
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
          |> Html.map LineMsg
      , emailField model
      , submitRow model
        [ nameField model
        , submitButton
        ]
      ]
    ]

content : Model -> List (Html Msg) -> Html Msg
content model =
  form
    [ Content |> showsAfter [model.prompt]
    , onSubmit SubmitLine
    ]

emailField : Model -> Html Msg
emailField model =
  input
    [ EmailField |> showsAfter [model.line.value]
    , onInput ChangeEmail
    , placeholder "E-mail Address"
    ] [ text model.email ]

nameField : Model -> Html Msg
nameField model =
  input
    [ class NameField
    , onInput ChangeName
    , placeholder "Name to Display (Optional)"
    ] [ text model.name ]

submitRow : Model -> List (Html Msg) -> Html Msg
submitRow model =
  div [ SubmitRow |> showsAfter [model.line.value, model.email] ]

submitButton : Html Msg
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
