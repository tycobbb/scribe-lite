module Scenes.Thanks.Styles exposing (Classes(..), styles)

import Css exposing (..)
import Styles.Colors as Colors
import Styles.Fonts exposing (fontLarge)
import Styles.Mixins exposing (scene)
import Styles.Helpers exposing (Styles, stylesNamed)

type Classes
  = Scene
  | Message
  | Button

styles : Styles c m
styles =
  stylesNamed "Thanks"
    [ class Scene
      [ scene
      ]
    , class Message
      [ fontLarge
      , color Colors.white
      , adjacentSiblings
        [ class Message
          [ marginTop (px 45)
          ]
        ]
      ]
    , class Button
      [ marginTop (px 65)
      ]
    ]
