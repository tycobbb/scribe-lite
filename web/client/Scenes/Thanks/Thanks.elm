module Scenes.Thanks.Thanks exposing (view)

import Html exposing (..)
import Scenes.Thanks.Styles exposing (Classes(..), styles)
import Views.Button as Button

-- view
{ class, classes } = styles

view : a -> Html m
view model =
  div [ class Scene ]
    [ p [ class Message ]
      [ text "Thanks for writing" ]
    , p [ class Message ]
      [ text "At 8PM tonight, today's story will be e-mailed to you." ]
    , div [ class Button ]
      [ Button.view "Refresh Page" True ]
    ]
