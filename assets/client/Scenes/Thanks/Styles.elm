module Scenes.Thanks.Styles exposing (Classes(..), styles)

import Css exposing (..)
import Styles.Colors as Colors
import Styles.Fonts exposing (fontLarge)
import Styles.Mixins exposing (scene, sceneContent)
import Styles.Helpers exposing (Styles, stylesNamed)

type Classes
  = Scene
  | Content
  | Message
  | Button

styles : Styles c m
styles =
  stylesNamed "Thanks"
    [ class Scene
      [ scene
      , justifyContent center
      ]
    , class Content
      [ sceneContent
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
