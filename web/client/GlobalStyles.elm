module GlobalStyles exposing (styles)

import Css exposing (..)
import Css.Elements exposing (body, p, textarea)
import SharedStyles exposing (..)
import StyleHelpers exposing (Styles, stylesNamed)

fontFace : List Mixin -> Snippet
fontFace =
  selector "@font-face"

fontSrc : String -> Mixin
fontSrc src =
  property "src" ("url(" ++ src ++ ")")

styles : Styles c c1 m m1
styles =
  stylesNamed "global"
    [ body
      [ fontMontserrat
      , fontWeightRegular
      , lineHeight (num 1.35)
      , backgroundColor (hex "FFFEF5")
      ]
    , p
      [ margin (px 0)
      ]
    , textarea
      [ fontFamily inherit
      , fontSize inherit
      , fontWeight inherit
      , lineHeight (num 1.35)
      ]
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
