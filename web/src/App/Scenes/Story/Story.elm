module Scenes.Story.Story exposing (State, Model, Msg, init, view, update, background)

import Html.Styled as H exposing (Html)
import Html.Styled.Attributes exposing (value, placeholder)
import Html.Styled.Events exposing (onInput, onSubmit)
import Json.Encode as JE
import Json.Decode as JD exposing (field)
import Scenes.Story.Line as Line
import Views.Button as Button
import Socket
import Helpers exposing (Change, withCmd, withoutCmd, withEvent, withoutEvent, withoutEffects)
import Css exposing (..)
import Styles.Fonts as Fonts
import Styles.Colors as Colors
import Styles.Mixins as Mixins

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
  in
    initModel line
      |> withCmd (Cmd.map LineMsg lineCmd)
      |> withEvent joinStory

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
        -- |> withCmd (Navigation.newUrl "/thanks")
        |> withoutCmd
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
joinStory : Socket.Event Msg
joinStory =
  Socket.noEvent
  -- Channel.init room
    -- |> Channel.onJoin JoinStory
    -- |> Socket.Event.Join

submitLine : Model -> Socket.Event Msg
submitLine model =
  Socket.noEvent
  -- Push.init "add:line" room
  --   |> Push.withPayload (encodeLine model)
  --   |> Push.onOk SubmitOk
  --   |> Socket.Event.Push

leaveStory : Socket.Event Msg
leaveStory =
  Socket.noEvent
  -- Socket.Event.Leave room

-- request data
type alias StoryPrompt =
  { text : String
  , name : String
  }

decodePrompt : JD.Value -> Result JD.Error StoryPrompt
decodePrompt =
  JD.decodeValue
    (JD.map2 StoryPrompt
      (field "text" JD.string)
      (field "name" JD.string))

encodeLine : Model -> JE.Value
encodeLine model =
  JE.object
    [ ("text",  JE.string model.line.value)
    , ("email", JE.string model.email)
    , ("name",  JE.string model.name)
    ]

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
    formS [ onSubmit SubmitLine ]

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
