module Scenes.Thanks.Thanks exposing (Model, Msg, init, view, update, background)

import Browser.Navigation as Nav
import Css exposing (..)
import Css.Global as CG
import Html.Styled as H exposing (Html)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Events exposing (onClick)

import Session exposing (Session)
import State
import Styles.Fonts as Fonts
import Styles.Colors as Colors
import Views.Button as Button
import Views.Scene as Scene

-- constants
background : Color
background =
  Colors.primary

-- init
type alias State =
  State.Pair Model Msg

type Model
  = None

init : State
init =
  None
    |> State.withoutCmd

-- update
type Msg
  = RefreshPage

update : Session -> Msg -> Model -> State
update session msg model =
  case msg of
    RefreshPage ->
      model
        |> State.withCmd (Nav.replaceUrl session.key "/")

-- view
view : Model -> Html Msg
view _ =
  Scene.view [ sceneA ]
    [ Scene.viewContent []
      [ messageS []
        [ H.text "Thanks for writing" ]
      , messageS []
        [ H.text "At 8PM tonight, today's story will be e-mailed to you." ]
      , buttonS [ onClick RefreshPage ]
        [ Button.view "Refresh Page" True ]
      ]
    ]

-- styles
sceneA =
  css
    [ justifyContent center ]

messageS =
  H.styled H.p
    [ Fonts.lg
    , color Colors.white
    , CG.adjacentSiblings
      [ CG.span
        [ marginTop (px 45)
        ]
      ]
    ]

buttonS =
  H.styled H.div
    [ marginTop (px 65)
    ]
