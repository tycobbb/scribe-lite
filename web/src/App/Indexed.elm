module Indexed exposing (..)

import State

type alias Indexed a =
  { index : Int
  , item  : a
  }

-- operations
indexable : (Indexed a -> b) -> Int -> a -> b
indexable other index =
  (Indexed index) >> other

withIndex : Int -> (a, Cmd m) -> (Indexed a, Cmd m)
withIndex index =
  State.map (Indexed index) identity
