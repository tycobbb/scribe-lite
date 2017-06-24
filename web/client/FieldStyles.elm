module FieldStyles exposing (Classes(..), namespace, css, inline)

import Css exposing (..)
import Css.Namespace as C
import Html.CssHelpers exposing (withNamespace)
import Rules exposing (Rules, rules)
import SharedStyles exposing (..)

type alias Height = Float

-- stylesheet
type Classes
  = Wrapper
  | Input
  | ShadowInput
  | ShadowText
  | Placeholder
  | CountAnchor
  | Count

namespace : Html.CssHelpers.Namespace String class id msg
namespace =
  withNamespace "field"

field : Mixin
field =
  mixin
    [ overflow auto
    , property "word-wrap" "break-word"
    , property "white-space" "pre-wrap"
    ]

css : Stylesheet
css =
  (stylesheet << C.namespace namespace.name)
    [ class Wrapper
      [ position relative
      , fontLarge
      ]
    , class Input
      [ field
      , width (pct 100)
      , padding (px 0)
      , zIndex (int 1)
      , borderStyle none
      , outlineStyle none
      , backgroundColor transparent
      , cursor pointer
      , resize none
      ]
    , class ShadowInput
      [ position absolute
      , top (px 0)
      , bottom (px 0)
      , left (px 0)
      , right (px 0)
      , property "pointer-events" "none"
      ]
    , class ShadowText
      [ field
      , color transparent
      ]
    , class Placeholder
      [ color (hex "F2F1E7")
      ]
    , class CountAnchor
      [ position relative
      ]
    , class Count
      [ position absolute
      , top (px 0)
      , left (px 10)
      , color (hex "F2F1E7")
      ]
    ]

-- inline
inputHeight : Height -> Rules m
inputHeight value =
  rules [ height (px value) ]

inline :
  { hidden : Rules m
  , height : Height -> Rules m
  }

inline =
  { hidden = rules
    [ display none
    ]
  , height = inputHeight
  }
