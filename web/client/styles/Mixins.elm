module Styles.Mixins exposing (..)

import Css exposing (..)
import Styles.Colors exposing (lightGray)

textField : Mixin
textField =
  mixin
    [ borderStyle none
    , outlineStyle none
    , backgroundColor transparent
    , cursor pointer
    , pseudoElement "placeholder"
      [ color lightGray
      , property "transition" "padding-left 0.15s"
      , focus
        [ paddingLeft (px 10)
        ]
      ]
    ]
