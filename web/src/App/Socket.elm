module Socket exposing (..)

-- socket
type Socket m =
  None

init : Socket m
init = None

-- msg
type Msg m
  = NoMsg

-- event
type Event m
  = NoEvent

-- type Event m
--   = Join (Channel.Channel m)
--   | Leave String
--   | Push (Push.Push m)
--   | None

noEvent : Event m
noEvent = NoEvent

-- none : Event m
-- none = None

-- actions
map : (msg -> m) -> Event msg -> Event m
map mapMsg event =
  NoEvent

-- map : (msg -> m) -> Event msg -> Event m
-- map mapMsg event =
--   case event of
--     Join msg ->
--       Join (Channel.map mapMsg msg)
--     Leave name ->
--       Leave name
--     Push msg ->
--       Push (Push.map mapMsg msg)
--     None ->
--       None

send : Socket m -> Event m -> (Socket m, Cmd (Socket m))
send socket event =
  (socket, Cmd.none)

-- send : Socket.Socket m -> Event m -> (Socket.Socket m, Cmd (Socket.Msg m))
-- send socket event =
--   case event of
--     Join channel ->
--       Socket.join channel socket
--     Leave name ->
--       Socket.leave name socket
--     Push push ->
--       Socket.push push socket
--     NoEvent ->
--       (socket, Cmd.none)

