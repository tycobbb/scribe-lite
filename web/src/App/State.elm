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
map : (a1 -> a2) -> (m1 -> m2) -> Base a1 m1 -> Base a2 m2
map toModel toMsg =
  Tuple.mapBoth toModel (Cmd.map toMsg)

merge : (a1 -> a2 -> a2) -> (m1 -> m2) -> Base a1 m1 -> Base a2 m2 -> Base a2 m2
merge toModel toMsg (newModel, newMsg) (model, msg) =
  ( toModel newModel model
  , Cmd.batch
    [ msg
    , Cmd.map toMsg newMsg
    ]
  )
joinCmd : Cmd m -> Base a m -> Base a m
joinCmd other ( model, cmd ) =
  ( model
  , Cmd.batch [ cmd, other ]
  )
