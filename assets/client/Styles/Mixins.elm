module Styles.Mixins exposing (..)

import Css exposing (..)
import Styles.Colors exposing (lightGray)

scene : Style
scene =
  batch
    [ displayFlex
    , flexDirection column
    , width (vw 100)
    , height (vh 100)
    , minHeight minContent
    ]

sceneContent : Style
sceneContent =
  batch
    [ displayFlex
    , flexDirection column
    , margin2 (px 60) (px 85)
    ]

textField : Style
textField =
  batch
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
