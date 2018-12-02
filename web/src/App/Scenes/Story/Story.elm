module Scenes.Story.Story exposing (State, Model, Msg, init, subscriptions, update, view, background)

import Browser.Navigation as Nav
import Css exposing (..)
import Html.Styled as H exposing (Html)
import Html.Styled.Attributes exposing (value, placeholder)
import Html.Styled.Events exposing (onInput, onSubmit)
import Json.Encode as JE
import Json.Decode as JD exposing (field)

import Scenes.Story.Line as Line
import Session exposing (Session)
import Socket
import State
import Styles.Fonts as Fonts
import Styles.Colors as Colors
import Styles.Mixins as Mixins
import Views.Button as Button

-- constants
background : Color
background =
  Colors.secondaryBackground

-- state
type alias State =
  ( Model
  , Cmd Msg
  )

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
      |> State.joinCmd (Socket.push joinStory)

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
  | SetupStory (Result Socket.Error StoryPrompt)
  | AddLine
  | AddLineOk (Result Socket.Error Bool)

update : Msg -> Model -> Session -> State
update msg model session =
  case msg of
    LineMsg lineMsg ->
      Line.update lineMsg model.line
        |> setLine model
    ChangeEmail email ->
      { model | email = email }
        |> State.withNoCmd
    ChangeName name ->
      { model | name = name }
        |> State.withNoCmd
    SetupStory prompt ->
      prompt
        |> setPrompt model
        |> State.withNoCmd
    AddLine ->
      model
        |> State.withCmd (addLine model)
    AddLineOk _ ->
      Debug.log "add line ok" model
        |> State.withCmd (Nav.pushUrl session.key "/thanks")
        |> State.joinCmd leaveStory

setLine : Model -> Line.State -> (Model, Cmd Msg)
setLine model (field, cmd) =
  { model | line = field }
    |> State.withCmd (Cmd.map LineMsg cmd)

setPrompt : Model -> Result Socket.Error StoryPrompt -> Model
setPrompt model result =
  result
    |> Result.map (\{ text, name } -> { model | prompt = text, author = name })
    |> Result.withDefault model

-- subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ setupStory
    , addLineOk
    ]

-- socket.messages
joinStory : Socket.Message
joinStory =
  { name = "STORY.JOIN"
  , data = JE.null
  }

-- socket.subscribe
type alias StoryPrompt =
  { text : String
  , name : String
  }

setupStory : Sub Msg
setupStory =
  let
    decoder =
      JD.map2 StoryPrompt
        (JD.field "text" JD.string)
        (JD.field "name" JD.string)
  in
    decoder
      |> Socket.Event "STORY.SETUP"
      |> Socket.subscribe SetupStory

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

addLineOk : Sub Msg
addLineOk =
  JD.null True
    |> Socket.Event "STORY.ADD_LINE.OK"
    |> Socket.subscribe AddLineOk

-- STORY.LEAVE
leaveStory : Cmd Msg
leaveStory =
  Cmd.none

-- view
view : Model -> Html Msg
view model =
  sceneS []
    [ sceneContentS []
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
sceneS =
  H.styled H.section
    [ Mixins.scene
    ]

sceneContentS =
  H.styled H.div
    [ Mixins.sceneContent
    ]

headerS =
  H.styled H.header
    [ Fonts.md
    , alignSelf center
    , color Colors.gray0
    ]

formS =
  H.styled H.form
    [ flex (int 1)
    , displayFlex
    , flexDirection column
    , justifyContent center
    ]

authorS =
  H.styled H.p
    [ marginBottom (px 20)
    , Fonts.sm
    , color Colors.gray0
    ]

promptS =
  H.styled H.p
    [ marginBottom (px 60)
    , Fonts.lg
    , color Colors.secondary
    ]

emailFieldS =
  H.styled H.input
    [ Mixins.textField
    , marginTop (px 80)
    , marginBottom (px 10)
    , transform (translateY (px 20))
    , Fonts.md
    , color Colors.gray1
    ]

nameFieldS =
  H.styled H.input
    [ Mixins.textField
    , flex (int 1)
    , Fonts.sm
    , color Colors.gray1
    ]

submitRowS =
  H.styled H.div
    [ displayFlex
    , justifyContent spaceBetween
    , alignItems center
    , transform (translateY (px 20))
    ]
