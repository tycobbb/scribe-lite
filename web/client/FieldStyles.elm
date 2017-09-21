module FieldStyles exposing (Classes(..), styles, inline, lineHeight)

import Css exposing (..)
import Styles.Fonts exposing (..)
import Styles.Helpers exposing (Rules, rules, Styles, stylesNamed)
import Styles.Mixins exposing (textField)

-- constants
lineHeight : Float
lineHeight = 81

-- stylesheet
type Classes
  = Wrapper
  | Input
  | ShadowInput
  | ShadowField
  | ShadowText
  | Placeholder
  | Count

field : Mixin
field =
  mixin
    [ overflow auto
    , property "word-wrap" "break-word"
    , property "white-space" "pre-wrap"
    ]

styles : Styles c c1 m m1
styles =
  stylesNamed "field"
    [ class Wrapper
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
    , class Placeholder
      [ marginLeft (px 20)
      , color (hex "F2F1E7")
      ]
    , class Count
      [ color (hex "F2F1E7")
      ]
    ]

-- inline
inline :
  { height : Float -> Rules m
  }

inline =
  { height = px >> height >> List.singleton >> rules
  }
