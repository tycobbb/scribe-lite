module MainStyles exposing (Classes(..), styles)

import Css exposing (..)
import Css.Elements exposing (span)
import Styles.Fonts exposing (..)
import Styles.Colors exposing (lightGray, gray, black)
import Styles.Mixins exposing (textField)
import Styles.Helpers exposing (Styles, stylesNamed)

type Classes
  = Container
  | Inner
  | Header
  | Content
  | Text
  | Prompt
  | Author
  | EmailField
  | Row
  | NameField
  | SubmitButton
  | Chevron

edge : Mixin
edge =
  mixin
    [ property "content" "''"
    , display block
    , position absolute
    , width (px 3)
    , height (px 20)
    , borderRadius (px 1.5)
    , backgroundColor (hex "FFB6B6")
    , hover
      [ backgroundColor (hex "FFECD1")
      ]
    ]

styles : Styles c c1 m m1
styles =
  stylesNamed "main"
    [ class Container
      [ displayFlex
      , flexDirection column
      , alignItems center
      , padding2 (px 60) (px 85)
      ]
    , class Header
      [ fontMedium
      , color lightGray
      ]
    , class Content
      [ flex (int 1)
      , flexDirection column
      , justifyContent center
      ]
    , class Text
      [ flex (int 1)
      , displayFlex
      , flexDirection column
      , justifyContent center
      ]
    , class Prompt
      [ marginBottom (px 60)
      , fontLarge
      , color (hex "F5E9CB")
      ]
    , class Author
      [ marginBottom (px 20)
      , fontSmall
      , color lightGray
      ]
    , class EmailField
      [ textField
      , fontMedium
      , marginTop (px 80)
      , marginBottom (px 10)
      , color gray
      , pseudoElement "placeholder"
        [ color lightGray
        ]
      ]
    , class Row
      [ displayFlex
      , justifyContent spaceBetween
      , alignItems center
      ]
    , class NameField
      [ flex (int 1)
      , textField
      , fontSmall
      , color gray
      , pseudoElement "placeholder"
        [ color lightGray
        ]
      ]
    , class SubmitButton
      [ fontMedium
      , padding (px 0)
      , border unset
      , backgroundImage unset
      , backgroundColor transparent
      , color (hex "FFB6B6")
      , cursor pointer
      , hover
        [ color (hex "FFECD1")
        ]
      , focus
        [ outline none
        ]
      , children
        [ span
          [ displayFlex
          , position relative
          ]
        ]
      ]
    , class Chevron
      [ paddingLeft (px 10)
      , paddingRight (px 12)
      , before
        [ edge
        , transforms
          [ rotate (deg -45)
          , translateY (px 3)
          ]
        ]
      , after
        [ edge
        , bottom (px 0)
        , transforms
          [ rotate (deg 45)
          , translateY (px -3)
          ]
        ]
      ]
    ]
