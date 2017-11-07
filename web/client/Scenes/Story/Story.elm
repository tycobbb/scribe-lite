module Scenes.Story.Story exposing (State, Model, Msg, init, view, update, background)

import Html exposing (..)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onInput, onSubmit)
import Css exposing (Color)
import Json.Encode as JE
import Json.Decode as JD exposing (field)
import Navigation
import Phoenix.Channel as Channel
import Phoenix.Push as Push
import Scenes.Story.Styles exposing (Classes(..), styles)
import Scenes.Story.Line.Line as Line
import Views.Button as Button
import Socket.Event exposing (Event)
import Styles.Colors as Colors
import Helpers exposing (Change, withCmd, withoutCmd, withEvent, withoutEvent, withoutEffects)

-- constants
room : String
room =
  "story:unified"

background : Color
background =
  Colors.secondaryBackground

-- state
type alias State =
  Change Model Msg

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
    (line, lineCmd) =
      Line.init
  in
    initModel line
      |> withCmd (Cmd.map LineMsg lineCmd)
      |> withEvent joinStory

initModel : Line.Model -> Model
initModel line =
  { line = line
  , prompt = ""
  , author = ""
  , email = ""
  , name = ""
  }

-- update
type Msg
  = LineMsg Line.Msg
  | ChangeEmail String
  | ChangeName String
  | JoinStory JE.Value
  | SubmitLine
  | SubmitOk JE.Value

update : Msg -> Model -> State
update msg model =
  case msg of
    LineMsg lineMsg ->
      Line.update lineMsg model.line
        |> setLine model
        |> withoutEvent
    ChangeEmail email ->
      { model | email = email }
        |> withoutEffects
    ChangeName name ->
      { model | name = name }
        |> withoutEffects
    JoinStory raw ->
      decodePrompt raw
        |> setPrompt model
        |> withoutEffects
    SubmitLine ->
      model
        |> withoutCmd
        |> withEvent (submitLine model)
    SubmitOk _ ->
      model
        |> withCmd (Navigation.newUrl "/thanks")
        |> withEvent leaveStory

setLine : Model -> Line.State -> (Model, Cmd Msg)
setLine model (field, cmd) =
  { model | line = field }
    |> withCmd (Cmd.map LineMsg cmd)

setPrompt : Model -> Result e StoryPrompt -> Model
setPrompt model result =
  result
    |> Result.map (\{ text, name } -> { model | prompt = text, author = name })
    |> Result.withDefault { model | prompt = "You're starting from a blank slate." }

-- events
joinStory : Event Msg
joinStory =
  Channel.init room
    |> Channel.onJoin JoinStory
    |> Socket.Event.Join

submitLine : Model -> Event Msg
submitLine model =
  Push.init "add:line" room
    |> Push.withPayload (encodeLine model)
    |> Push.onOk SubmitOk
    |> Socket.Event.Push

leaveStory : Event Msg
leaveStory =
  Socket.Event.Leave room

-- request data
type alias StoryPrompt =
  { text : String
  , name : String
  }

decodePrompt : JD.Value -> Result String StoryPrompt
decodePrompt =
  JD.decodeValue
    (JD.map2 StoryPrompt
      (field "text" JD.string)
      (field "name" JD.string))

encodeLine : Model -> JE.Value
encodeLine model =
  JE.object
    [ ("text", JE.string model.line.value)
    , ("email", JE.string model.email)
    , ("name", JE.string model.name)
    ]

-- view
{ class, classes } = styles

view : Model -> Html Msg
view model =
  div [ class Scene ]
    [ div [ class Content ]
      [ div [ class Header ]
        [ text "Friday May 24 (2017)" ]
      , lineForm model
        [ p [ class Author ]
          [ text model.author ]
        , p [ class Prompt ]
          [ text model.prompt ]
        , Line.view model.line
            |> Html.map LineMsg
        , emailField model
        , submitRow model
          [ nameField model
          , Button.view "Submit" False
          ]
        ]
      ]
    ]

lineForm : Model -> List (Html Msg) -> Html Msg
lineForm model =
  if List.all (not << String.isEmpty) [model.prompt] then
    form
      [ class Body
      , onSubmit SubmitLine
      ]
  else
    (\_ -> text "")

emailField : Model -> Html Msg
emailField model =
  if List.all (not << String.isEmpty) [model.line.value] then
    input
      [ class EmailField
      , onInput ChangeEmail
      , placeholder "E-mail Address"
      ]
      [ text model.email
      ]
    else
      text ""

submitRow : Model -> List (Html Msg) -> Html Msg
submitRow model =
  if List.all (not << String.isEmpty) [model.line.value, model.email] then
    div [ class SubmitRow ]
  else
    (\_ -> text "")

nameField : Model -> Html Msg
nameField model =
  input
    [ class NameField
    , onInput ChangeName
    , placeholder "Name to Display (Optional)"
    ]
    [ text model.name
    ]

showsAfter : List String -> Classes -> Attribute m
showsAfter values klass =
  classes
    [ (klass, True)
    , (Visible, List.all (not << String.isEmpty) values)
    ]
