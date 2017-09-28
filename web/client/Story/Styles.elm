module Story.Styles exposing (Classes(..), styles)

import Css exposing (..)
import Css.Elements exposing (span, div)
import Styles.Fonts exposing (..)
import Styles.Mixins exposing (textField)
import Styles.Helpers exposing (Styles, stylesNamed)
import Styles.Colors as Colors

type Classes
  = Container
  | Header
  | Content
  | Prompt
  | Author
  | EmailField
  | SubmitRow
  | NameField
  | SubmitButton
  | Chevron
  | Visible

styles : Styles c c1 m m1
styles =
  stylesNamed "Story"
    [ class Container
      [ displayFlex
      , flexDirection column
      ]
    , class Header
      [ fontMedium
      , alignSelf center
      , color Colors.lightGray
      ]
    , class Content
      [ animatesVisibility
      , flex (int 1)
      , displayFlex
      , flexDirection column
      , justifyContent center
      ]
    , class Prompt
      [ marginBottom (px 60)
      , fontLarge
      , color Colors.accent
      ]
    , class Author
      [ marginBottom (px 20)
      , fontSmall
      , color Colors.lightGray
      ]
    , class EmailField
      [ textField
      , animatesVisibility
      , fontMedium
      , marginTop (px 80)
      , marginBottom (px 10)
      , transform (translateY (px 20))
      , color Colors.gray
      ]
    , class SubmitRow
      [ animatesVisibility
      , displayFlex
      , justifyContent spaceBetween
      , alignItems center
      , transform (translateY (px 20))
      ]
    , class NameField
      [ flex (int 1)
      , textField
      , fontSmall
      , color Colors.gray
      ]
    , class SubmitButton
      [ fontMedium
      , padding (px 0)
      , border unset
      , backgroundImage unset
      , backgroundColor transparent
      , cursor pointer
      , color Colors.primary
      , property "transition" "color 0.15s"
      , chevronStyles
        [ backgroundColor Colors.primary
        , property "transition" "background-color 0.15s"
        ]
      , hover
        [ color Colors.primaryHighlight
        , chevronStyles
          [ backgroundColor Colors.primaryHighlight
          ]
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
    , class Visible
      [ opacity (int 1)
      , transform none
      ]
    ]

animatesVisibility : Mixin
animatesVisibility =
  mixin
    [ property "transition" "opacity 0.2s, transform 0.2s"
    , opacity (int 0)
    ]

chevronLeg : Mixin
chevronLeg =
  mixin
    [ property "content" "''"
    , display block
    , position absolute
    , width (px 3)
    , height (px 20)
    , borderRadius (px 1.5)
    ]

chevronStyles : List Mixin -> Mixin
chevronStyles styles =
  mixin
    [ descendants
      [ class Chevron
        [ before styles
        , after styles
        ]
      ]
    ]
