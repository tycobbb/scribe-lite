module FieldStyles exposing (styles)

import Rules exposing (..)
import Css exposing (..)

type alias Height = Float

field : Mixin
field =
  mixin
    [ overflow auto
    , property "word-wrap" "break-word"
    , property "white-space" "pre-wrap"
    ]

inputHeight : Height -> Rules m
inputHeight value =
  rules [ height (px value) ]

styles :
  { wrapper : Rules m
  , input : Rules m
  , shadowInput : Rules m
  , shadowText : Rules m
  , placeholder : Rules m
  , countAnchor : Rules m
  , count : Rules m
  , hidden : Rules m
  , height : Height -> Rules m
  }

styles =
  { wrapper = rules
    [ position relative,
      fontSize (px 42)
    ]
  , input = rules
    [ field
    , width (pct 100)
    , padding (px 0)
    , zIndex (int 1)
    , borderStyle none
    , outlineStyle none
    , backgroundColor transparent
    , cursor pointer
    , resize none
    ]
  , shadowInput = rules
    [ position absolute
    , top (px 0)
    , bottom (px 0)
    , left (px 0)
    , right (px 0)
    , property "pointer-events" "none"
    ]
  , shadowText = rules
    [ field
    , color transparent
    ]
  , placeholder = rules
    [ color (hex "F2F1E7")
    ]
  , countAnchor = rules
    [ position relative
    ]
  , count = rules
    [ position absolute
    , top (px 0)
    , left (px 5)
    , color (hex "F2F1E7")
    ]
  , hidden = rules
    [ display none
    ]
  , height = inputHeight
  }
