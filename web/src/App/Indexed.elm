module Indexed exposing (..)

import State

type alias Indexed a =
  { index : Int
  , item  : a
  }

map : (a -> b) -> Indexed a -> Indexed b
map fn indexed =
  Indexed indexed.index (fn indexed.item)

join : (a -> b -> c) -> Indexed a -> Indexed b -> Maybe c
join fn first second =
  if first.index /= second.index then
    Nothing
  else
    Just (fn first.item second.item)

-- mapDefault : a -> a
mapDefault : (a -> b) -> Indexed a -> Maybe (Indexed b) -> Indexed b
mapDefault fn indexed =
  Maybe.withDefault (map fn indexed)

-- join3 : (a -> b -> c -> d) -> Indexed a -> Indexed b -> Indexed c -> Maybe (Indexed d)
-- join3 fn first second third =
--   if first.index /= second.index && second.index /= third.index then
--     Indexed first.index Nothing
--   else
--     Indexed first.index (Just (fn first.item second.item third.item))

withDefault : Indexed a -> Maybe (Indexed a) -> Indexed a
withDefault =
  Maybe.withDefault

-- operations
indexable : (Indexed a -> b) -> Int -> a -> b
indexable other index =
  (Indexed index) >> other

withIndex : Int -> (a, Cmd m) -> (Indexed a, Cmd m)
withIndex index =
  State.map (Indexed index) identity
