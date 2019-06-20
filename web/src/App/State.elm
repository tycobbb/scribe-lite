module State exposing (..)

-- types --
type alias Pair a m =
  ( a
  , Cmd m
  )

-- impls/init --
just : a -> Pair a m
just =
  withCmd Cmd.none

withCmd : Cmd m -> a -> Pair a m
withCmd cmd model =
  ( model, cmd )

withoutCmd : a -> Pair a m
withoutCmd =
  just

-- operations
map : (a1 -> a2) -> (m1 -> m2) -> Pair a1 m1 -> Pair a2 m2
map toModel toMsg =
  Tuple.mapBoth toModel (Cmd.map toMsg)

merge : (a1 -> a2 -> a2) -> (m1 -> m2) -> Pair a1 m1 -> Pair a2 m2 -> Pair a2 m2
merge toModel toMsg (newModel, newMsg) (model, msg) =
  ( toModel newModel model
  , Cmd.batch
    [ msg
    , Cmd.map toMsg newMsg
    ]
  )

joinCmd : Cmd m -> Pair a m -> Pair a m
joinCmd other ( model, cmd ) =
  ( model
  , Cmd.batch [ cmd, other ]
  )
