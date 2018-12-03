module State exposing (..)

type alias Base a m =
  ( a
  , Cmd m
  )

-- initialization
just : a -> Base a m
just =
  withCmd Cmd.none

withCmd : Cmd m -> a -> Base a m
withCmd cmd model =
  ( model, cmd )

withoutCmd : a -> Base a m
withoutCmd =
  just

-- operations
map : (a1 -> a2) -> (m1 -> m2) -> (a1, Cmd m1) -> (a2, Cmd m2)
map toModel toMsg ( model, cmd ) =
  ( toModel model
  , Cmd.map toMsg cmd
  )

mapCmd : (m1 -> m2) -> (a, Cmd m1) -> (a, Cmd m2)
mapCmd toMsg =
  map identity toMsg

joinCmd : Cmd m -> Base a m -> Base a m
joinCmd other ( model, cmd ) =
  ( model
  , Cmd.batch [ cmd, other ]
  )
