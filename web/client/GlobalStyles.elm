module GlobalStyles exposing (css)

import Css exposing (..)
import Css.Elements exposing (body, p)
import Css.Namespace exposing (namespace)

css : Stylesheet
css =
  (stylesheet << namespace "global")
    [ body
      [ property "font-family" "Montserrat"
      ]
    , p
      [ margin (px 0)
      ]
    , selector "@font-face"
      [ property "font-family" "Montserrat"
      , fontWeight (int 400)
      , property "src" "url(/fonts/Montserrat-Regular.ttf)"
      ]
    , selector "@font-face"
      [ property "font-family" "Montserrat"
      , fontWeight (int 700)
      , property "src" "url(/fonts/Montserrat-Bold.ttf)"
      ]
    ]
