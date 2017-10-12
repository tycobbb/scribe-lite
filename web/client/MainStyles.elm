module MainStyles exposing (Classes(..), styles, inline, duration)

import Css exposing (..)
import Styles.Helpers exposing (Styles, Rules, stylesNamed, rules)

-- constants
translation : number
translation = 50

duration : number
duration = 300

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
      , transition ["background-color"]
      ]
    , class Scene
      [ displayFlex
      , position absolute
      , top (px 0)
      , bottom (px 0)
      , left (px 0)
      , right (px 0)
      , transition ["top", "opacity"]
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

transition : List String -> Mixin
transition attributes =
  let
    durationPart =
      " " ++ toString duration ++ "ms"
    toTransition =
      (flip String.append) durationPart
  in
    attributes
      |> List.map toTransition >> String.join ", "
      |> property "transition"

-- inline
inline : { backgroundColor : ColorValue c -> Rules m }
inline =
  { backgroundColor = backgroundColor >> List.singleton >> rules
  }
