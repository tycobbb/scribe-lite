module Views.Button exposing (..)

import Css exposing (..)
import Html as H exposing (Html)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Styles.Fonts as Fonts
import Styles.Colors as Colors

-- view
view : String -> Bool -> Html m
view title isInverted =
  H.button
    [ styles.classes
      [ ( Element, True )
      , ( Inverted, isInverted )
      ]
    ]
    [ H.span []
      [ H.text title
      , H.div [ styles.class Chevron ] []
      ]
    ]

viewButton =
  H.button
    [ css
      [ Fonts.medium
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
    ]

-- css
inverted =
  Css.batch
    [ setColor Colors.secondary Colors.secondaryHighlight
    ]

chevron =
  Css.batch
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

chevronLeg =
  Css.batch
    [ property "content" "''"
    , display block
    , position absolute
    , width (px 3)
    , height (px 20)
    , borderRadius (px 1.5)
    ]

chevronStyles : List Style -> Style
chevronStyles styles =
  Css.batch
    [ descendants
      [ chevron
        [ before styles
        , after styles
        ]
      ]
    ]

setColor : ColorValue c -> ColorValue c1 -> Style
setColor base highlight =
  Css.batch
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
