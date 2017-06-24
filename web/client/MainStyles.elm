module MainStyles exposing (Classes(..), namespace, css)

import Css exposing (..)
import Css.Namespace as C
import Html.CssHelpers exposing (Namespace, withNamespace)
import SharedStyles exposing (..)

type Classes
  = Container
  | Inner
  | Header
  | Content
  | Text
  | Prompt
  | Author

namespace : Namespace String class id msg
namespace =
  withNamespace "main"

css : Stylesheet
css =
  (stylesheet << C.namespace namespace.name)
    [ class Container
      [ displayFlex
      , height (vh 100)
      , backgroundColor (hex "FFFEF5")
      ]
    , class Inner
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
      ]
    , class Text
      [ displayFlex
      , flexDirection column
      , justifyContent center
      , height (pct 50)
      ]
    , class Prompt
      [ marginBottom (px 50)
      , fontLarge
      , color (hex "F5E9CB")
      ]
    , class Author
      [ marginBottom (px 20)
      , fontSmall
      , color (hex "F2F1E7")
      ]
    ]
