module Compose.Line.Styles exposing (Classes(..), styles, inline, lineHeight)

import Css exposing (..)
import Styles.Fonts exposing (..)
import Styles.Helpers exposing (Rules, rules, Styles, stylesNamed)
import Styles.Mixins exposing (textField)
import Styles.Colors as Colors

-- constants
lineHeight : Float
lineHeight = 81

-- stylesheet
type Classes
  = Container
  | Input
  | ShadowInput
  | ShadowField
  | ShadowText
  | Count

styles : Styles c c1 m m1
styles =
  stylesNamed "compose-line"
    [ class Container
      [ position relative
      , fontLarge
      ]
    , class Input
      [ field
      , textField
      , display block
      , width (pct 100)
      , marginBottom (px -lineHeight)
      , padding (px 0)
      , zIndex (int 1)
      , resize none
      , color Colors.black
      ]
    , class ShadowInput
      [ position absolute
      , top (px 0)
      , left (px 0)
      , right (px 0)
      , property "pointer-events" "none"
      ]
    , class ShadowField
      [ field
      ]
    , class ShadowText
      [ color transparent
      ]
    , class Count
      [ color Colors.lightGray
      ]
    ]

field : Mixin
field =
  mixin
    [ overflow auto
    , property "word-wrap" "break-word"
    , property "white-space" "pre-wrap"
    ]

-- inline
inline :
  { height : Float -> Rules m
  }

inline =
  { height = px >> height >> List.singleton >> rules
  }
