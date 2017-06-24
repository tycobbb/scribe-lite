module SharedStyles exposing (..)

import Css exposing (fontSize, px)

fontSmall : Css.Mixin
fontSmall = fontSize (px 24)

fontMedium : Css.Mixin
fontMedium = fontSize (px 32)

fontLarge : Css.Mixin
fontLarge = fontSize (px 60)
