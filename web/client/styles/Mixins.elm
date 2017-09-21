module Styles.Mixins exposing (..)

import Css exposing (..)

-- fields
textField : Mixin
textField =
  mixin
    [ borderStyle none
    , outlineStyle none
    , backgroundColor transparent
    , cursor pointer
    ]
