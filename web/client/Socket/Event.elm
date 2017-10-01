module Socket.Event exposing (..)

import Phoenix.Socket as Socket
import Phoenix.Channel as Channel
import Phoenix.Push as Push

type Event m
  = Join (Channel.Channel m)
  | Leave String
  | Push (Push.Push m)
  | None

-- events
join : Channel.Channel m -> Event m
join = Join

leave : String -> Event m
leave = Leave

push : Push.Push m -> Event m
push = Push

none : Event m
none = None

-- actions
map : (msg -> m) -> Event msg -> Event m
map message event =
  case event of
    Join channel ->
      Join (Channel.map message channel)
    Leave name ->
      Leave name
    Push push ->
      Push (Push.map message push)
    None ->
      None

send : Socket.Socket m -> Event m -> (Socket.Socket m, Cmd (Socket.Msg m))
send socket event =
  case event of
    Join channel ->
      Socket.join channel socket
    Leave name ->
      Socket.leave name socket
    Push push ->
      Socket.push push socket
    None ->
      (socket, Cmd.none)

