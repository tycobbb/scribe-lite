module Styles.Theme exposing (global)

import Html.Styled exposing (Html)
import Css exposing (..)
import Css.Global as CG
import Styles.Fonts as Fonts

-- theme
global : Html msg
global =
  CG.global
    [ CG.html
      [ property "padding-left" "calc(100vw - 100%)"
      , Fonts.serif
      , Fonts.regular
      , lineHeight (num 1.35)
      ]
    , fontFace
      [ Fonts.serif
      , Fonts.regular
      , fontSrc "/fonts/Montserrat-Regular.ttf"
      ]
    , fontFace
      [ Fonts.serif
      , Fonts.medium
      , fontSrc "/fonts/Montserrat-Medium.ttf"
      ]
    ]

-- helpers
fontFace : List Style -> CG.Snippet
fontFace =
  CG.selector "@font-face"

fontSrc : String -> Style
fontSrc src =
  property "src" ("url(" ++ src ++ ")")
