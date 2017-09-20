module MainStyles exposing (Classes(..), styles)

import Css exposing (..)
import Styles.Fonts exposing (..)
import Styles.Helpers exposing (Styles, stylesNamed)

type Classes
  = Container
  | Inner
  | Header
  | Content
  | Text
  | Prompt
  | Author

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
      , color (hex "F2F1E7")
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
      , color (hex "F2F1E7")
      ]
    ]
