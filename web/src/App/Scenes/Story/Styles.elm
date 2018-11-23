module Scenes.Story.Styles exposing (..)

import Css exposing (..)
import Styles.Fonts as Fonts
import Styles.Colors as Colors
import Styles.Mixins as Mixins

scene : Style
scene =
  Css.batch
    [ Mixins.scene
    ]

content : Style
content =
  Css.batch
    [ Mixins.sceneContent
    ]

header : Style
header =
  Css.batch
    [ Fonts.md
    , alignSelf center
    , color Colors.gray0
    ]

body : Style
body =
  Css.batch
    [ animatesVisibility
    , flex (int 1)
    , displayFlex
    , flexDirection column
    , justifyContent center
    ]

prompt : Style
prompt =
  Css.batch
    [ marginBottom (px 60)
    , Fonts.lg
    , color Colors.secondary
    ]

author : Style
author =
  Css.batch
    [ marginBottom (px 20)
    , Fonts.sm
    , color Colors.gray0
    ]

emailField : Style
emailField =
  Css.batch
    [ Mixins.textField
    , animatesVisibility
    , marginTop (px 80)
    , marginBottom (px 10)
    , transform (translateY (px 20))
    , Fonts.md
    , color Colors.gray1
    ]

submitRow : Style
submitRow =
  Css.batch
    [ animatesVisibility
    , displayFlex
    , justifyContent spaceBetween
    , alignItems center
    , transform (translateY (px 20))
    ]

nameField : Style
nameField =
  Css.batch
    [ Mixins.textField
    , flex (int 1)
    , Fonts.sm
    , color Colors.gray1
    ]

visible : Style
visible =
  Css.batch
    [ opacity (int 1)
    , transform none
    ]

animatesVisibility : Style
animatesVisibility =
  Css.batch
    [ property "transition" "opacity 0.2s, transform 0.2s"
    ]
