module Styles.Mixins exposing (..)

import Css exposing (..)

textField : Mixin
textField =
  mixin
    [ borderStyle none
    , outlineStyle none
    , backgroundColor transparent
    , cursor pointer
    ]
