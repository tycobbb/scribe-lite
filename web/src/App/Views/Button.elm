module Views.Button exposing (..)

import Css exposing (..)
import Css.Global as CG
import Html.Styled as H exposing (Html)
import Html.Styled.Attributes exposing (class)
import Styles.Fonts as Fonts
import Styles.Colors as Colors

-- constants
chevronClass = "scribe-button-chevron"

-- view
view : String -> Bool -> Html m
view title isInverted =
  buttonS isInverted []
    [ titleS []
      [ H.text title
      , chevronS [ class chevronClass ] []
      ]
    ]

-- styles
buttonS isInverted =
  H.styled H.button
    [ padding (px 0)
    , border unset
    , Fonts.medium
    , paletteB isInverted
    , backgroundImage unset
    , backgroundColor transparent
    , cursor pointer
    , property "transition" "color 0.15s"
    , focus
      [ outline none
      ]
    ]

titleS =
  H.styled H.span
    [ displayFlex
    , position relative
    ]

chevronS =
  let
    legB = Css.batch
      [ property "content" "''"
      , display block
      , position absolute
      , width (px 3)
      , height (px 20)
      , borderRadius (px 1.5)
      , property "transition" "background-color 0.15s"
      ]
  in
    H.styled H.div
      [ paddingLeft (px 10)
      , paddingRight (px 12)
      , before
        [ legB
        , transforms
          [ rotate (deg -45)
          , translateY (px 3)
          ]
        ]
      , after
        [ legB
        , bottom (px 0)
        , transforms
          [ rotate (deg 45)
          , translateY (px -3)
          ]
        ]
      ]

chevronB : List Style -> Style
chevronB styles =
  Css.batch
    [ CG.descendants
      [ CG.class chevronClass
        [ before styles
        , after styles
        ]
      ]
    ]

paletteB : Bool -> Style
paletteB isInverted =
  let
    (base, highlight) =
      if isInverted
        then (Colors.secondary, Colors.secondaryHighlight)
        else (Colors.primary, Colors.primaryHighlight)
  in
    Css.batch
      [ color base
      , chevronB
        [ backgroundColor base
        ]
      , hover
        [ color highlight
        , chevronB
          [ backgroundColor highlight
          ]
        ]
      ]
