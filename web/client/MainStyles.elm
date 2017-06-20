module MainStyles exposing (styles)

import Rules exposing (..)
import Css exposing (..)

styles :
  { container : Rules m
  , inner : Rules m
  , header : Rules m
  , content : Rules m
  , text : Rules m
  , prompt : Rules m
  , author : Rules m
  }

styles =
  { container = rules
    [ displayFlex
    , height (vh 100)
    , backgroundColor (hex "FFFEF5")
    ]
  , inner = rules
    [ displayFlex
    , flexDirection column
    , alignItems center
    , padding (px 60)
    ]
  , header = rules
    [ fontSize (px 28)
    , color (hex "F2F1E7")
    ]
  , content = rules
    [ flex (int 1)
    ]
  , text = rules
    [ displayFlex
    , flexDirection column
    , justifyContent center
    , height (pct 70)
    ]
  , prompt = rules
    [ marginBottom (px 10)
    , fontSize (px 42)
    , color (hex "F5E9CB")
    ]
  , author = rules
    [ marginBottom (px 10)
    , fontSize (px 18)
    , color (hex "F2F1E7")
    ]
  }
