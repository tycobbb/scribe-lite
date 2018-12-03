module Styles.Mixins exposing (textFieldB)

import Css exposing (..)
import Styles.Colors as Colors

textFieldB : Style
textFieldB =
  Css.batch
    [ outlineStyle none
    , cursor pointer
    , pseudoElement "placeholder"
      [ color Colors.gray0
      , property "transition" "padding-left 0.15s"
      , focus
        [ paddingLeft (px 10)
        ]
      ]
    ]
