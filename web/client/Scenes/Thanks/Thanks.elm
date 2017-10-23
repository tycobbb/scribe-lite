module Scenes.Thanks.Thanks exposing (Model, Msg, view, update, background)

import Html exposing (..)
import Html.Events exposing (onClick)
import Css exposing (Color)
import Navigation
import Scenes.Thanks.Styles exposing (Classes(..), styles)
import Views.Button as Button
import Styles.Colors as Colors

-- constants
background : Color
background =
  Colors.primary

-- init
type Model
  = None

init : Model
init = None

-- update
type Msg
  = RefreshPage

update : a -> Msg -> ( Model, Cmd m )
update model msg =
  case msg of
    RefreshPage ->
      ( None, Navigation.newUrl "/" )

-- view
{ class } = styles

view : Html Msg
view =
  div [ class Scene ]
    [ p [ class Message ]
      [ text "Thanks for writing" ]
    , p [ class Message ]
      [ text "At 8PM tonight, today's story will be e-mailed to you." ]
    , div [ class Button, onClick RefreshPage ]
      [ Button.view "Refresh Page" True ]
    ]
