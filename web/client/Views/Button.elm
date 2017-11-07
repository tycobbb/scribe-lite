module Views.Button exposing (..)

import Html as El exposing (Html)
import Css exposing (..)
import Css.Elements exposing (span)
import Styles.Fonts exposing (..)
import Styles.Helpers exposing (Styles, stylesNamed)
import Styles.Colors as Colors

-- view
view : String -> Bool -> Html m
view title isInverted =
  El.button
    [ styles.classes
      [ ( Element, True )
      , ( Inverted, isInverted )
      ]
    ]
    [ El.span []
      [ El.text title
      , El.div [ styles.class Chevron ] []
      ]
    ]

-- css
type Classes
  = Element
  | Inverted
  | Chevron

styles : Styles c m
styles =
  stylesNamed "Button"
    [ class Element
      [ fontMedium
      , padding (px 0)
      , border unset
      , backgroundImage unset
      , backgroundColor transparent
      , cursor pointer
      , setColor Colors.primary Colors.primaryHighlight
      , property "transition" "color 0.15s"
      , chevronStyles
        [ property "transition" "background-color 0.15s"
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
    , class Inverted
      [ setColor Colors.secondary Colors.secondaryHighlight
      ]
    , class Chevron
      [ paddingLeft (px 10)
      , paddingRight (px 12)
      , before
        [ chevronLeg
        , transforms
          [ rotate (deg -45)
          , translateY (px 3)
          ]
        ]
      , after
        [ chevronLeg
        , bottom (px 0)
        , transforms
          [ rotate (deg 45)
          , translateY (px -3)
          ]
        ]
      ]
    ]

chevronLeg : Style
chevronLeg =
  batch
    [ property "content" "''"
    , display block
    , position absolute
    , width (px 3)
    , height (px 20)
    , borderRadius (px 1.5)
    ]

chevronStyles : List Style -> Style
chevronStyles styles =
  batch
    [ descendants
      [ class Chevron
        [ before styles
        , after styles
        ]
      ]
    ]

setColor : ColorValue c -> ColorValue c1 -> Style
setColor base highlight =
  batch
    [ color base
    , chevronStyles
      [ backgroundColor base
      ]
    , hover
      [ color highlight
      , chevronStyles
        [ backgroundColor highlight
        ]
      ]
    ]
