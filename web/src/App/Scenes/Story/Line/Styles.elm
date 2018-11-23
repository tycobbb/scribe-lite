module Scenes.Story.Line.Styles exposing (lineHeight)

import Css exposing (..)
import Styles.Fonts as Fonts
import Styles.Colors as Colors
import Styles.Mixins as Mixins

-- constants
lineHeight : Float
lineHeight = 81

-- stylesheet
container : Style
container =
  Css.batch
    [ Fonts.lg
    , position relative
    ]

input : Style
input =
  Css.batch
    [ field
    , Mixins.textField
    , display block
    , width (pct 100)
    , marginBottom (px -lineHeight)
    , padding (px 0)
    , zIndex (int 1)
    , resize none
    , color Colors.black
    ]

shadowInput : Style
shadowInput =
  Css.batch
    [ position absolute
    , top (px 0)
    , left (px 0)
    , right (px 0)
    , property "pointer-events" "none"
    ]

shadowField : Style
shadowField =
  Css.batch
    [ field
    ]

shadowText : Style
shadowText =
  Css.batch
    [ color transparent
    ]

count : Style
count =
  Css.batch
    [ color Colors.gray0
    ]

field : Style
field =
  batch
    [ overflow auto
    , property "word-wrap" "break-word"
    , property "white-space" "pre-wrap"
    ]

-- inline
-- inline : { height : Float -> Rules m }
-- inline =
--   { height = px >> height >> List.singleton >> rules
--   }
