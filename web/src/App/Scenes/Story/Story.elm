module Scenes.Story.Story exposing (State, Model, Msg, init, subscriptions, update, view, background)

import Browser.Navigation as Nav
import Css exposing (..)
import Html.Styled as H exposing (Html)
import Html.Styled.Attributes exposing (attribute, placeholder, value)
import Html.Styled.Events exposing (onInput, onSubmit)
import Json.Encode as JE
import Json.Decode as JD exposing (field)

import Session exposing (Session)
import Socket
import State
import Styles.Colors as Colors
import Styles.Fonts as Fonts
import Styles.Mixins as Mixins
import Timers

import Scenes.Story.Editor as Editor
import Views.Scene as Scene
import Views.Button as Button

-- constants
background : Color
background =
  Colors.secondaryBackground

-- state
type alias State =
  State.Pair Model Msg

init : State
init =
  Editor.init
    |> State.map initModel EditorMsg

-- model
type alias Model =
  { editor   : Editor.Model
  , isQueued : Bool
  , date     : String
  , title    : String
  , subtitle : String
  , email    : String
  , name     : String
  }

initModel : Editor.Model -> Model
initModel editor =
  { editor   = editor
  , isQueued = True
  , date     = "Friday May 24 (2017)"
  , title    = ""
  , subtitle = ""
  , email    = ""
  , name     = ""
  }

-- model/queries
isValid : Model -> Bool
isValid model =
  not model.isQueued && isLineValid model && isEmailValid model

isLineValid : Model -> Bool
isLineValid model =
  not <| String.isEmpty model.editor.value

isEmailValid : Model -> Bool
isEmailValid model =
  String.contains "@" model.email

-- model/commands
setEditor : Editor.Model -> Model -> Model
setEditor editor model =
  { model | editor = editor }

setPrompt : Prompt -> Model -> Model
setPrompt { text, name } model =
  { model
  | isQueued = False
  , title    = text
  , subtitle = Maybe.withDefault "" name
  }

setQueue : Position -> Model -> Model
setQueue { behind } model =
  { model
  | isQueued = True
  , title    = "You're the " ++ toOrdinal behind ++ " person in line."
  }

-- model/helpers
toOrdinal : Int -> String
toOrdinal number =
  let
    string = String.fromInt number
  in
    case (modBy 10 (number // 10), modBy 10 number) of
      (1, _) -> string ++ "th"
      (_, 1) -> string ++ "st"
      (_, 2) -> string ++ "nd"
      (_, 3) -> string ++ "rd"
      (_, _) -> string ++ "th"

-- update
type Msg
  = ChangeEmail String
  | ChangeName String
  | AddLine
  | ShowQueue Position
  | ShowPrompt Prompt
  | ShowThanks Bool
  | CheckPulse Bool
  | EditorMsg Editor.Msg
  | Ignored

update : Session -> Msg -> Model -> State
update session msg model =
  case msg of
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
        |> setQueue position
        |> State.withoutCmd
    ShowPrompt prompt ->
      model
        |> setPrompt prompt
        |> State.withoutCmd
    ShowThanks _ ->
      model
        |> State.withCmd (Nav.replaceUrl session.key "/thanks")
    CheckPulse _ ->
      Debug.log "Story" "Checking pulse..."
        |> always (State.just model)
    EditorMsg lineMsg ->
      State.just model
        |> State.merge setEditor EditorMsg (Editor.update lineMsg model.editor)
    Ignored ->
      State.just model

-- subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ showQueue
    , showPrompt
    , showThanks
    ]

-- socket/in/SHOW_QUEUE
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

-- socket/in/SHOW_PREVIOUS_LINE
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

-- socket/in/CHECK_PULSE
checkPulse : Sub Msg
checkPulse =
  JD.null True
    |> Socket.Event "CHECK_PULSE"
    |> Socket.subscribe CheckPulse Ignored

-- socket/out/ADD_LINE
addLine : Model -> Cmd Msg
addLine model =
  let
    data =
      JE.object
        [ ("text",  JE.string model.editor.value)
        , ("email", JE.string model.email)
        , ("name",  JE.string model.name)
        ]
  in
    data
      |> Socket.MessageOut "ADD_LINE"
      |> Socket.push

-- socket/in/SHOW_THANKS
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
      [ viewHeader model
      , viewForm model
        [ viewEditor model
        , viewEmailField model
        , submitRowS []
          [ viewNameField model
          , viewSubmit model
          ]
        ]
      ]
    ]

-- view/header
viewHeader : Model -> Html m
viewHeader model =
  headerS []
    [ dateS []
      [ H.text "Friday May 24 (2017)" ]
    , subtitleS []
      [ H.text model.subtitle ]
    , titleS []
      [ H.text model.title ]
    ]

-- view/form
viewForm : Model -> List (Html Msg) -> Html Msg
viewForm model =
  formS [ onSubmit AddLine ]

-- view/editor
viewEditor : Model -> Html Msg
viewEditor model =
  if model.isQueued
    then H.text ""
    else Editor.view model.editor |> H.map EditorMsg

-- view/author
viewEmailField : Model -> Html Msg
viewEmailField model =
  emailFieldS
    [ onInput ChangeEmail
    , placeholder "E-mail Address"
    , attribute "type" "email"
    , value model.email
    ] []

viewNameField : Model -> Html Msg
viewNameField model =
  if not <| isEmailValid model then
    H.text ""
  else
    nameFieldS
      [ onInput ChangeName
      , placeholder "Name to Display (Optional)"
      , value model.name
      ] []

-- view/submit
viewSubmit : Model -> Html Msg
viewSubmit model =
  if not <| isValid model
    then H.text ""
    else Button.view "Submit" False

-- view/header/styles
headerS : List (H.Attribute m) -> List (Html m) -> Html m
headerS =
  H.styled H.header
    [ displayFlex
    , flexDirection column
    ]

dateS : List (H.Attribute m) -> List (Html m) -> Html m
dateS =
  H.styled H.p
    [ Fonts.md
    , alignSelf center
    , color Colors.gray0
    ]

subtitleS : List (H.Attribute m) -> List (Html m) -> Html m
subtitleS =
  H.styled H.p
    [ Fonts.sm
    , height (em 1)
    , color Colors.gray0
    ]

titleS : List (H.Attribute m) -> List (Html m) -> Html m
titleS =
  H.styled H.p
    [ marginTop (px 20)
    , Fonts.lg
    , color Colors.secondary
    ]

-- view/form/styles
formS : List (H.Attribute m) -> List (Html m) -> Html m
formS =
  H.styled H.form
    [ flex (int 1)
    , displayFlex
    , flexDirection column
    , marginTop (px 60)
    ]

-- view/author/styles
submitRowS : List (H.Attribute m) -> List (Html m) -> Html m
submitRowS =
  H.styled H.div
    [ displayFlex ]

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
