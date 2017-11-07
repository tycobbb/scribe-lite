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
  | SceneReady
  | SceneIn
  | SceneOut

styles : Styles c m
styles =
  stylesNamed "Main"
    [ class Stage
      [ position relative
      , transition ["background-color"]
      ]
    , class Scene
      [
      ]
    , class SceneReady
      [ position absolute
      , top (px 0)
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

transition : List String -> Style
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
