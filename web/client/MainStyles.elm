module MainStyles exposing (styles)

import Rules exposing (..)
import Css exposing (..)

styles :
  { container : Rules m
  , field : Rules m
  , prompt : Rules m
  , input : Rules m
  }

styles =
  { container = rules
    [ displayFlex
    , justifyContent center
    , height (vh 100)
    , padding (px 30)
    , backgroundColor (hex "F5E47F")
    ]
  , field = rules
    [ displayFlex
    , flexDirection column
    , justifyContent stretch
    ]
  , prompt = rules
    [ marginBottom (px 10)
    , color (hex "FFFFFF")
    ]
  , input = rules
    [ color (hex "88CBF5")
    ]
  }
