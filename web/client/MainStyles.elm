module MainStyles exposing (Classes(..), styles)

import Css exposing (..)
import Styles.Helpers exposing (stylesNamed)

type Classes
  = Stage
  | Scene
  | Visible

styles : Styles.Helpers.Styles c m
styles =
  stylesNamed "Main"
    [ class Stage
      [ flex (int 1)
      , position relative
      ]
    , class Scene
      [ displayFlex
      , position absolute
      , top (px 20)
      , bottom (px 0)
      , left (px 0)
      , right (px 0)
      , opacity (int 0)
      , property "transition" "top 0.15s, opacity 0.15s"
      ]
    , class Visible
      [ top (px 0)
      , opacity (int 1)
      ]
    ]
