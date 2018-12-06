module Scenes.Story.Story exposing (State, Model, Msg, init, subscriptions, update, view, background)

import Browser.Navigation as Nav
import Css exposing (..)
import Html.Styled as H exposing (Html)
import Html.Styled.Attributes exposing (attribute, placeholder, value)
import Html.Styled.Events exposing (onInput, onSubmit)
import Json.Encode as JE
import Json.Decode as JD exposing (field)

import Scenes.Story.Line as Line
import Session exposing (Session)
import Socket
import State
import Styles.Colors as Colors
import Styles.Fonts as Fonts
import Styles.Mixins as Mixins
import Views.Button as Button
import Views.Scene as Scene

-- constants
background : Color
background =
  Colors.secondaryBackground

-- state
type alias State =
  State.Base Model Msg

type alias Model =
  { line   : Line.Model
  , prompt : String
  , author : String
  , email  : String
  , name   : String
  }

init : State
init =
  let
    (line, lineCmd) =
      Line.init
        |> State.mapCmd LineMsg
  in
    initModel line
      |> State.withCmd lineCmd
      |> State.joinCmd joinStory

initModel : Line.Model -> Model
initModel line =
  { line   = line
  , prompt = ""
  , author = ""
  , email  = ""
  , name   = ""
  }

-- update
type Msg
  = LineMsg Line.Msg
  | ChangeEmail String
  | ChangeName String
  | JoinStoryDone (Socket.Res StoryPrompt)
  | AddLine
  | AddLineDone (Socket.Res Bool)
  | Ignored

update : Session -> Msg -> Model -> State
update session msg model =
  case msg of
    LineMsg lineMsg ->
      model
        |> setLine (Line.update lineMsg model.line)
    ChangeEmail email ->
      { model | email = email }
        |> State.withoutCmd
    ChangeName name ->
      { model | name = name }
        |> State.withoutCmd
    JoinStoryDone result ->
      case result of
        Ok prompt ->
          model
            |> setPrompt prompt
            |> State.withoutCmd
        Err _ ->
          State.just model
    AddLine ->
      model
        |> State.withCmd (addLine model)
    AddLineDone result ->
      case result of
        Ok _ ->
          model
            |> State.withCmd (Nav.replaceUrl session.key "/thanks")
            |> State.joinCmd leaveStory
        Err _ ->
          State.just model
    Ignored ->
      State.just model

setLine : Line.State -> Model -> State
setLine (line, cmd) model =
  { model | line = line }
    |> State.withCmd (Cmd.map LineMsg cmd)

setPrompt : StoryPrompt -> Model -> Model
setPrompt { text, name } model =
  { model | prompt = text, author = name }

-- subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ joinStoryDone
    , addLineDone
    ]

-- STORY.JOIN
type alias StoryPrompt =
  { text : String
  , name : String
  }

joinStory : Cmd Msg
joinStory =
  JE.null
    |> Socket.Message "STORY.JOIN"
    |> Socket.push

joinStoryDone : Sub Msg
joinStoryDone =
  let
    decoder =
      JD.map2 StoryPrompt
        (JD.field "text" JD.string)
        (JD.field "name" JD.string)
  in
    decoder
      |> Socket.Event "STORY.JOIN.DONE"
      |> Socket.subscribe JoinStoryDone Ignored

-- STORY.ADD_LINE
addLine : Model -> Cmd Msg
addLine model =
  let
    data =
      JE.object
        [ ("text",  JE.string model.line.value)
        , ("email", JE.string model.email)
        , ("name",  JE.string model.name)
        ]
  in
    data
      |> Socket.Message "STORY.ADD_LINE"
      |> Socket.push

addLineDone : Sub Msg
addLineDone =
  JD.null True
    |> Socket.Event "STORY.ADD_LINE.DONE"
    |> Socket.subscribe AddLineDone Ignored

-- STORY.LEAVE
leaveStory : Cmd Msg
leaveStory =
  Cmd.none

-- view
view : Model -> Html Msg
view model =
  Scene.view []
    [ Scene.viewContent []
      [ headerS []
        [ H.text "Friday May 24 (2017)" ]
      , viewForm model
        [ authorS []
          [ H.text model.author ]
        , promptS []
          [ H.text model.prompt ]
        , Line.view model.line
            |> H.map LineMsg
        , viewEmailField model
        , viewSubmitRow model
          [ viewNameField model
          , Button.view "Submit" False
          ]
        ]
      ]
    ]

viewForm : Model -> List (Html Msg) -> Html Msg
viewForm model =
  if String.isEmpty model.prompt then
    (\_ -> H.text "")
  else
    formS [ onSubmit AddLine ]

viewEmailField : Model -> Html Msg
viewEmailField model =
  if String.isEmpty model.line.value then
    H.text ""
  else
    emailFieldS
      [ onInput ChangeEmail
      , placeholder "E-mail Address"
      , attribute "type" "email"
      , value model.email
      ] []

viewNameField : Model -> Html Msg
viewNameField model =
  nameFieldS
    [ onInput ChangeName
    , placeholder "Name to Display (Optional)"
    , value model.name
    ] []

viewSubmitRow : Model -> List (Html Msg) -> Html Msg
viewSubmitRow model =
  if List.any String.isEmpty [model.line.value, model.email] then
    (\_ -> H.text "")
  else
    submitRowS []

-- styles
headerS : List (H.Attribute m) -> List (Html m) -> Html m
headerS =
  H.styled H.header
    [ Fonts.md
    , alignSelf center
    , color Colors.gray0
    ]

formS : List (H.Attribute m) -> List (Html m) -> Html m
formS =
  H.styled H.form
    [ flex (int 1)
    , displayFlex
    , flexDirection column
    , justifyContent center
    ]

authorS : List (H.Attribute m) -> List (Html m) -> Html m
authorS =
  H.styled H.p
    [ marginBottom (px 20)
    , Fonts.sm
    , color Colors.gray0
    ]

promptS : List (H.Attribute m) -> List (Html m) -> Html m
promptS =
  H.styled H.p
    [ marginBottom (px 60)
    , Fonts.lg
    , color Colors.secondary
    ]

emailFieldS : List (H.Attribute m) -> List (Html m) -> Html m
emailFieldS =
  H.styled H.input
    [ Mixins.textFieldB
    , marginTop (px 80)
    , marginBottom (px 10)
    , Fonts.md
    , color Colors.gray1
    ]

nameFieldS : List (H.Attribute m) -> List (Html m) -> Html m
nameFieldS =
  H.styled H.input
    [ Mixins.textFieldB
    , flex (int 1)
    , Fonts.sm
    , color Colors.gray1
    ]

submitRowS : List (H.Attribute m) -> List (Html m) -> Html m
submitRowS =
  H.styled H.div
    [ displayFlex
    , justifyContent spaceBetween
    , alignItems center
    , transform (translateY (px 20))
    ]
