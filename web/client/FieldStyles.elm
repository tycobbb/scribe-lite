module FieldStyles exposing (styles)

import Rules exposing (..)
import Css exposing (..)

styles :
  { wrapper : Rules m
  , input : Rules m
  , shadowInput : Rules m
  , shadowText : Rules m
  , placeholder : Rules m
  , count : Rules m
  , hidden : Rules m
  }

styles =
  { wrapper = rules
    [ position relative,
      fontSize (px 42)
    ]
  , input = rules
    [ width (pct 100)
    , padding (px 0)
    , zIndex (int 1)
    , borderStyle none
    , outlineStyle none
    , backgroundColor transparent
    , cursor pointer
    , overflow auto
    , resize none
    , fontSize (px 42)
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
    [ marginRight (px 10)
    , color transparent
    ]
  , placeholder = rules
    [ color (hex "F2F1E7")
    ]
  , count = rules
    [ color (hex "F2F1E7")
    ]
  , hidden = rules
    [ display none
    ]
  }
