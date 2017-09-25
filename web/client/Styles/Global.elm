module Styles.Global exposing (styles)

import Css exposing (..)
import Css.Elements exposing (body, p, textarea, input)
import Styles.Fonts exposing (..)
import Styles.Helpers exposing (Styles, stylesNamed)
import Styles.Colors as Colors

fontFace : List Mixin -> Snippet
fontFace =
  selector "@font-face"

fontSrc : String -> Mixin
fontSrc src =
  property "src" ("url(" ++ src ++ ")")

inheritsTextStyle : Mixin
inheritsTextStyle =
  mixin
    [ fontFamily inherit
    , fontSize inherit
    , fontWeight inherit
    , lineHeight inherit
    ]

styles : Styles c c1 m m1
styles =
  stylesNamed "global"
    [ body
      [ fontMontserrat
      , fontWeightRegular
      , lineHeight (num 1.35)
      , backgroundColor Colors.background
      ]
    , p
      [ margin (px 0)
      ]
    , textarea
      [ inheritsTextStyle ]
    , input
      [ inheritsTextStyle ]
    , fontFace
      [ fontMontserrat
      , fontWeightRegular
      , fontSrc "/fonts/Montserrat-Regular.ttf"
      ]
    , fontFace
      [ fontMontserrat
      , fontWeightMedium
      , fontSrc "/fonts/Montserrat-Medium.ttf"
      ]
    ]
