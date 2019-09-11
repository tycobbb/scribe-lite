module Scenes.Story.Pulse exposing (Model, onRefresh, onFind, find, refresh, setTimestamp)

import Browser.Events
import Json.Decode as JD
import Json.Encode as JE
import Task
import Time

import Socket
import State

-- types --
type alias Model a =
  { a
  | timestamp : Maybe Time.Posix
  }

type alias State a m =
  State.Pair (Model a) m

-- impls --
-- impls/events
onRefresh : m -> Sub m
onRefresh msg =
  Sub.batch
    [ Browser.Events.onMouseMove (JD.succeed msg)
    , Browser.Events.onKeyPress (JD.succeed msg)
    ]

onFind : (Bool -> m) -> m -> Sub m
onFind toMsg toIgnore =
  JD.null True
    |> Socket.Event "FIND_PULSE"
    |> Socket.subscribe toMsg toIgnore

-- impls/commands
-- impls/commands/find
find : Model a -> State a m
find model =
  model
    |> State.withCmd (save model)

save : Model a -> Cmd m
save model =
  let
    push data =
      data
        |> Socket.MessageOut "SAVE_PULSE"
        |> Socket.push
  in
    model.timestamp
      |> Maybe.map (encode >> push)
      |> Maybe.withDefault Cmd.none

encode : Time.Posix -> JE.Value
encode timestamp =
  JE.object
    [ ("timestamp", JE.int (Time.posixToMillis timestamp))
    ]

-- impls/commands/refresh
refresh : (Time.Posix -> m) -> Model a -> State a m
refresh msg model =
  model
    |> State.withCmd (Task.perform msg Time.now)

setTimestamp : Time.Posix -> Model a -> State a m
setTimestamp timestamp model =
  { model | timestamp = Just timestamp }
    |> State.withoutCmd
