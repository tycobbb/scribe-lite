module Scenes.Story.Styles exposing (Classes(..), styles)

import Css exposing (..)
import Styles.Fonts exposing (..)
import Styles.Mixins exposing (scene, textField)
import Styles.Helpers exposing (Styles, stylesNamed)
import Styles.Colors as Colors

type Classes
  = Scene
  | Header
  | Content
  | Prompt
  | Author
  | EmailField
  | SubmitRow
  | NameField
  | Visible

styles : Styles c m
styles =
  stylesNamed "Story"
    [ class Scene
      [ scene
      , backgroundColor Colors.secondaryBackground
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
      , color Colors.secondary
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
