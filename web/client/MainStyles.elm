module MainStyles exposing (styles)

import Rules exposing (..)
import Css exposing (..)

styles :
  { container : Rules m
  , header : Rules m
  , content : Rules m
  , prompt : Rules m
  , author : Rules m
  }

styles =
  { container = rules
    [ displayFlex
    , flexDirection column
    , alignItems center
    , height (vh 100)
    , padding (px 60)
    , backgroundColor (hex "FFFEF5")
    ]
  , header = rules
    [ fontSize (px 28)
    , color (hex "F2F1E7")
    ]
  , content = rules
    [ displayFlex
    , flexDirection column
    , justifyContent stretch
    , marginTop (px 140)
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
