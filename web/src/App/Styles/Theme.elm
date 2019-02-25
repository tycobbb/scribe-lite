module Styles.Theme exposing (global)

import Css exposing (..)
import Css.Global as CG
import Html.Styled exposing (Html)
import Styles.Fonts as Fonts

-- theme
global : Html msg
global =
  CG.global
    [ CG.body
      [ Fonts.serif
      , Fonts.regular
      , lineHeight (num 1.35)
      ]
    ]

-- helpers
fontFace : List Style -> CG.Snippet
fontFace =
  CG.selector "@font-face"

fontSrc : String -> Style
fontSrc src =
  property "src" ("url(" ++ src ++ ")")
