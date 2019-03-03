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
import Timers
import Views.Button as Button
import Views.Scene as Scene

-- constants
background : Color
background =
  Colors.secondaryBackground

-- state
type alias State =
  State.Pair Model Msg

type alias Model =
  { line   : Line.Model
  , prompt : String
  , author : String
  , email  : String
  , name   : String
  }

init : State
init =
  Line.init
    |> State.map initModel LineMsg
    -- workaround https://github.com/elm/compiler/issues/1776
    |> State.joinCmd (Timers.async JoinStory)

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
  = JoinStory
  | ChangeEmail String
  | ChangeName String
  | AddLine
  | ShowQueue Position
  | ShowPrompt Prompt
  | ShowThanks Bool
  | LineMsg Line.Msg
  | Ignored

update : Session -> Msg -> Model -> State
update session msg model =
  case msg of
    JoinStory ->
      model
        |> State.withCmd joinStory
    ChangeEmail email ->
      { model | email = email }
        |> State.withoutCmd
    ChangeName name ->
      { model | name = name }
        |> State.withoutCmd
    AddLine ->
      model
        |> State.withCmd (addLine model)
    ShowQueue position ->
      model
        |> setPrompt ({ text = "You waiting for " ++ String.fromInt position.behind ++ " people to finish.", name = Just "In line!" })
        |> State.withoutCmd
    ShowPrompt prompt ->
      model
        |> setPrompt prompt
        |> State.withoutCmd
    ShowThanks _ ->
      model
        |> State.withCmd (Nav.replaceUrl session.key "/thanks")
    LineMsg lineMsg ->
      State.just model
        |> State.merge setLine LineMsg (Line.update lineMsg model.line)
    Ignored ->
      State.just model

setLine : Line.Model -> Model -> Model
setLine line model =
  { model | line = line }

setPrompt : Prompt -> Model -> Model
setPrompt { text, name } model =
  { model | prompt = text, author = Maybe.withDefault "" name }

-- subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ showQueue
    , showPrompt
    , showThanks
    ]

-- socket.out: JOIN_STORY
joinStory : Cmd Msg
joinStory =
  JE.null
    |> Socket.MessageOut "JOIN_STORY"
    |> Socket.push

-- socket.in: SHOW_QUEUE
type alias Position =
  { behind : Int
  }

showQueue : Sub Msg
showQueue =
  let
    decodePosition =
      JD.map Position
        (JD.field "behind" JD.int)
  in
    decodePosition
      |> Socket.Event "SHOW_QUEUE"
      |> Socket.subscribe ShowQueue Ignored

-- socket.in: SHOW_PREVIOUS_LINE
type alias Prompt =
  { text : String
  , name : Maybe String
  }

showPrompt : Sub Msg
showPrompt =
  let
    decodePrompt =
      JD.map2 Prompt
        (JD.field "text" <| JD.string)
        (JD.field "name" <| JD.nullable JD.string)
  in
    decodePrompt
      |> Socket.Event "SHOW_PROMPT"
      |> Socket.subscribe ShowPrompt Ignored

-- socket.out: ADD_LINE
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
      |> Socket.MessageOut "ADD_LINE"
      |> Socket.push

-- socket.in: SHOW_THANKS
showThanks : Sub Msg
showThanks =
  JD.null True
    |> Socket.Event "SHOW_THANKS"
    |> Socket.subscribe ShowThanks Ignored

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
