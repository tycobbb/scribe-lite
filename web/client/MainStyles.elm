module MainStyles exposing (Classes(..), styles, inline)

import Css exposing (..)
import Styles.Helpers exposing (Styles, Rules, stylesNamed, rules)

-- constants
translation : number
translation = 50

-- stylesheet
type Classes
  = Stage
  | Scene
  | SceneIn
  | SceneOut

styles : Styles c m
styles =
  stylesNamed "Main"
    [ class Stage
      [ flex (int 1)
      , position relative
      , property "transition" "background-color 0.3s"
      ]
    , class Scene
      [ displayFlex
      , position absolute
      , top (px 0)
      , bottom (px 0)
      , left (px 0)
      , right (px 0)
      , property "transition" "top 0.3s, opacity 0.3s"
      ]
    , class SceneIn
      [ top (px translation)
      , opacity (int 0)
      ]
    , class SceneOut
      [ top (px -translation)
      , opacity (int 0)
      ]
    ]

-- inline
inline : { backgroundColor : ColorValue c -> Rules m }
inline =
  { backgroundColor = backgroundColor >> List.singleton >> rules
  }
