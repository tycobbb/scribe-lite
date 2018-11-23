module MainStyles exposing (duration)

import Css exposing (..)

-- constants
duration : number
duration = 300

translation : number
translation = 50

-- stylesheet
stage : Style
stage =
  Css.batch
      [ position relative
      , transition ["background-color"]
      ]

scene : Style
scene =
  Css.batch
    [
    ]

sceneReady : Style
sceneReady =
  Css.batch
    [ position absolute
    , top (px 0)
    , left (px 0)
    , right (px 0)
    , transition ["top", "opacity"]
    ]

sceneIn : Style
sceneIn =
  Css.batch
    [ top (px translation)
    , opacity (int 0)
    ]

sceneOut : Style
sceneOut =
  Css.batch
    [ top (px -translation)
    , opacity (int 0)
    ]

transition : List String -> Style
transition attributes =
  let
    durationPart =
      " " ++ String.fromInt duration ++ "ms"
    toTransition attribute =
      attribute ++ durationPart
  in
    attributes
      |> List.map toTransition >> String.join ", "
      |> property "transition"

-- inline
-- inline : { backgroundColor : ColorValue c -> Rules m }
-- inline =
--   { backgroundColor = backgroundColor >> List.singleton >> rules
--   }
