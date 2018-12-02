module Scenes.Thanks.Thanks exposing (Model, Msg, init, view, update, background)

import Html.Styled as H exposing (Html)
import Html.Styled.Events exposing (onClick)
import Views.Button as Button
import State
import Css exposing (..)
import Css.Global as CG
import Styles.Fonts as Fonts
import Styles.Colors as Colors
import Styles.Mixins as Mixins

-- constants
background : Color
background =
  Colors.primary

-- init
type alias State =
  ( Model
  , Cmd Msg
  )

type Model
  = None

init : State
init =
  None
    |> State.withNoCmd

-- update
type Msg
  = RefreshPage

update : Msg -> Model -> State
update msg model =
  case msg of
    RefreshPage ->
      model
        -- |> State.withCmd (Navigation.newUrl "/")
        |> State.withNoCmd

-- view
view : Model -> Html Msg
view _ =
  sceneS []
    [ sceneContentS []
      [ messageS []
        [ H.text "Thanks for writing" ]
      , messageS []
        [ H.text "At 8PM tonight, today's story will be e-mailed to you." ]
      , buttonS [ onClick RefreshPage ]
        [ Button.view "Refresh Page" True ]
      ]
    ]

-- styles
sceneS =
  H.styled H.section
    [ Mixins.scene
    , justifyContent center
    ]

sceneContentS =
  H.styled H.div
    [ Mixins.sceneContent
    ]

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
