module Styles.Fonts exposing (..)

import Css exposing (..)

-- names
serif : Style
serif =
  fontFamilies [ "Montserrat" ]

-- weights
regular : Style
regular =
  fontWeight (int 400)

medium : Style
medium =
  fontWeight (int 600)

-- styles
sm : Style
sm =
  Css.batch
    [ fontSize (px 24)
    , regular
    ]

md : Style
md =
  Css.batch
    [ fontSize (px 32)
    , regular
    ]

lg : Style
lg =
  Css.batch
    [ fontSize (px 60)
    , medium
    ]
