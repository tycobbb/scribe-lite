module Scenes.Thanks.Thanks exposing (Model, Msg, init, view, update, background)

import Html exposing (..)
import Html.Events exposing (onClick)
import Css exposing (Color)
import Navigation
import Scenes.Thanks.Styles exposing (Classes(..), styles)
import Views.Button as Button
import Styles.Colors as Colors
import Helpers exposing (Change, withCmd, withoutEvent, withoutEffects)

-- constants
background : Color
background =
  Colors.primary

-- init
type alias State
  = Change Model Msg

type Model
  = None

init : State
init =
  withoutEffects None

-- update
type Msg
  = RefreshPage

update : Msg -> Model -> State
update msg _ =
  case msg of
    RefreshPage ->
      None
        |> withCmd (Navigation.newUrl "/")
        |> withoutEvent

-- view
{ class } = styles

view : Model -> Html Msg
view _ =
  div [ class Scene ]
    [ p [ class Message ]
      [ text "Thanks for writing" ]
    , p [ class Message ]
      [ text "At 8PM tonight, today's story will be e-mailed to you." ]
    , div [ class Button, onClick RefreshPage ]
      [ Button.view "Refresh Page" True ]
    ]
