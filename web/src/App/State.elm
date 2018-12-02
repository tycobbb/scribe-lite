module State exposing (..)

-- operations
map : (a1 -> a2) -> (m1 -> m2) -> (a1, Cmd m1) -> (a2, Cmd m2)
map toModel toMsg ( model, cmd ) =
  ( toModel model
  , Cmd.map toMsg cmd
  )

-- cmd
withCmd : Cmd m -> a -> (a, Cmd m)
withCmd cmd model =
  ( model, cmd )

withNoCmd : a -> (a, Cmd m)
withNoCmd =
  withCmd Cmd.none

mapCmd : (m1 -> m2) -> (a, Cmd m1) -> (a, Cmd m2)
mapCmd toMsg =
  map identity toMsg

joinCmd : Cmd m -> (a, Cmd m) -> (a, Cmd m)
joinCmd other ( model, cmd ) =
  ( model
  , Cmd.batch [ cmd, other ]
  )
