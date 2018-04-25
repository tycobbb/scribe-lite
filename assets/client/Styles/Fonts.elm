module Styles.Fonts exposing (..)

import Css exposing (..)

-- names (prefer font mixins below)
fontMontserrat : Style
fontMontserrat =
  fontFamilies [ "Montserrat" ]

-- weights (prefer font mixins below)
fontWeightRegular : Style
fontWeightRegular =
  fontWeight (int 400)

fontWeightMedium : Style
fontWeightMedium =
  fontWeight (int 600)

-- fonts
fontSmall : Style
fontSmall =
  batch
    [ fontSize (px 24)
    , fontWeightRegular
    ]

fontMedium : Style
fontMedium =
  batch
    [ fontSize (px 32)
    , fontWeightRegular
    ]

fontLarge : Style
fontLarge =
  batch
    [ fontSize (px 60)
    , fontWeightMedium
    ]
