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
import Helpers exposing (withCmd, withoutCmd, withEvent, withoutEvent)

-- constants
room : String
room =
  "story:unified"

background : Color
background =
  Colors.secondaryBackground

-- state
type alias State = ( Model, Cmd Msg, Event Msg )

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
      |> withEvent initEvent

initModel : Line.Model -> Model
initModel line =
  { line = line
  , prompt = ""
  , author = ""
  , email = ""
  , name = ""
  }

initEvent : Socket.Event.Event Msg
initEvent =
  Channel.init room
    |> Channel.onJoin JoinStory
    |> Socket.Event.Join

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
      ( { model | email = email }, Cmd.none )
        |> withoutEvent
    ChangeName name ->
      ( { model | name = name }, Cmd.none )
        |> withoutEvent
    JoinStory raw ->
      decodePrompt raw
        |> setPrompt model
        |> withoutEvent
    SubmitLine ->
      ( model, Cmd.none )
        |> withEvent (submitLine model)
    SubmitOk _ ->
      ( model, Navigation.newUrl "/thanks" )
        |> withoutEvent

setLine : Model -> Line.State -> (Model, Cmd Msg)
setLine model (field, cmd) =
  ( { model | line = field }
  , Cmd.map LineMsg cmd
  )

setPrompt : Model -> Result e StoryPrompt -> (Model, Cmd Msg)
setPrompt model result =
  result
    |> Result.map (\{ prompt, author } -> { model | prompt = prompt, author = author })
    |> Result.withDefault model
    |> withoutCmd

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
    |> Push.onOk SubmitOk
    |> Socket.Event.Push

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
  div [ class Scene ]
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

lineForm : Model -> List (Html Msg) -> Html Msg
lineForm model =
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

showsAfter : List String -> Classes -> Attribute m
showsAfter values klass =
  classes
    [ (klass, True)
    , (Visible, List.all (not << String.isEmpty) values)
    ]