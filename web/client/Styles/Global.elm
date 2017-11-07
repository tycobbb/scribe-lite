module Styles.Global exposing (styles)

import Css exposing (..)
import Css.Elements exposing (html, body, p, textarea, input)
import Styles.Fonts exposing (..)
import Styles.Helpers exposing (Styles, stylesNamed)

fontFace : List Style -> Snippet
fontFace =
  selector "@font-face"

fontSrc : String -> Style
fontSrc src =
  property "src" ("url(" ++ src ++ ")")

inheritsTextStyle : Style
inheritsTextStyle =
  batch
    [ fontFamily inherit
    , fontSize inherit
    , fontWeight inherit
    , lineHeight inherit
    ]

styles : Styles c m
styles =
  stylesNamed "global"
    [ html
      [ property "padding-left" "calc(100vw - 100%)"
      ]
    , body
      [ fontMontserrat
      , fontWeightRegular
      , lineHeight (num 1.35)
      ]
    , id "container"
      [ flex (int 1)
      , displayFlex
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
