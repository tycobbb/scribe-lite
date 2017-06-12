module FieldStyles exposing (styles)

import Rules exposing (..)
import Css exposing (..)

styles :
  { wrapper : Rules m
  , shadowInput : Rules m
  , input : Rules m
  , placeholder : Rules m
  , value : Rules m
  , outerCaret : Rules m
  , caret : Rules m
  , animating : Rules m
  , hidden : Rules m
  }

styles =
  { wrapper = rules
    [ position relative
    ]
  , shadowInput = rules
    [ position absolute
    , top (px 0)
    , bottom (px 0)
    , left (px 0)
    , right (px 0)
    , borderStyle none
    , outlineStyle none
    , backgroundColor transparent
    , color transparent
    ]
  , input = rules
    [ fontSize (px 42)
    , color (hex "272727")
    ]
  , placeholder = rules
    [ marginLeft (px 10)
    , color (hex "F2F1E7")
    ]
  , value = rules
    [ marginRight (px 10)
    ]
  , outerCaret = rules
    [ display inlineBlock
    , width (px 3)
    , height (px 50)
    ]
  , caret = rules
    [ height (pct 100)
    , marginTop (px 9)
    , backgroundColor (hex "272727")
    ]
  , animating = rules
    [ property "animation" "0.7s ease-in-out 0.0s infinite alternate blink"
    ]
  , hidden = rules
    [ display none
    ]
  }
