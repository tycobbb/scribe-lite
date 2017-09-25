module MainStyles exposing (Classes(..), styles)

import Css exposing (..)
import Styles.Helpers exposing (Styles, stylesNamed)

type Classes
  = Container

styles : Styles c c1 m m1
styles =
  stylesNamed "main"
    [ class Container
      [ padding2 (px 60) (px 85)
      ]
    ]
