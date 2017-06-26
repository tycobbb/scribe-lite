module SharedStyles exposing (..)

import Css exposing (..)

-- names (prefer font mixins below)
fontMontserrat : Css.Mixin
fontMontserrat =
  fontFamilies [ "Montserrat" ]

-- weights (prefer font mixins below)
fontWeightRegular : Css.Mixin
fontWeightRegular =
  fontWeight (int 400)

fontWeightMedium : Css.Mixin
fontWeightMedium =
  fontWeight (int 600)

-- fonts
fontSmall : Css.Mixin
fontSmall =
  mixin
    [ fontSize (px 24)
    , fontWeightRegular
    ]

fontMedium : Css.Mixin
fontMedium =
  mixin
    [ fontSize (px 32)
    , fontWeightRegular
    ]

fontLarge : Css.Mixin
fontLarge =
  mixin
    [ fontSize (px 60)
    , fontWeightMedium
    ]
