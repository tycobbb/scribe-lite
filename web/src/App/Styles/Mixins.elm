module Styles.Mixins exposing (..)

import Css exposing (..)
import Styles.Colors as Colors

scene : Style
scene =
  Css.batch
    [ displayFlex
    , flexDirection column
    , width (vw 100)
    , height (vh 100)
    , minHeight minContent
    ]

sceneContent : Style
sceneContent =
  Css.batch
    [ displayFlex
    , flexDirection column
    , margin2 (px 60) (px 85)
    ]

textField : Style
textField =
  Css.batch
    [ borderStyle none
    , outlineStyle none
    , backgroundColor transparent
    , cursor pointer
    , pseudoElement "placeholder"
      [ color Colors.gray0
      , property "transition" "padding-left 0.15s"
      , focus
        [ paddingLeft (px 10)
        ]
      ]
    ]
