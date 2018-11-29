port module Socket exposing (..)

import Json.Encode as JE
import Json.Decode as JD

-- socket
type Socket m =
  None

init : Socket m
init = None

port send : JE.Value -> Cmd msg
port recv : (JD.Value -> msg) -> Sub msg

listen : (Msg -> msg) -> Sub msg
listen toMsg =
  recv (\data -> data |> (JD.decodeValue decodeMessage) |> Debug.log "listen" |> (\_ -> toMsg NoMsg))

-- message
type alias Message =
  { name    : String
  , payload : Payload JD.Value
  }

type alias Payload v =
  Result Error v

decodeMessage : JD.Decoder Message
decodeMessage =
  JD.map2 Message
    (JD.field "name" JD.string)
    (decodePayload)

decodePayload : JD.Decoder (Payload JD.Value)
decodePayload =
  let
    toResult error data =
      data
        |> Result.fromMaybe error
        |> Result.mapError (Maybe.withDefault unknownError)
  in
    JD.map2 toResult
      (JD.maybe (JD.field "error" decodeError))
      (JD.maybe (JD.field "data" JD.value))

-- error
type alias Error =
  { message : String
  }

decodeError : JD.Decoder Error
decodeError =
  JD.map Error
    (JD.field "message" JD.string)

unknownError : Error
unknownError =
  Error "Unknown Error."

-- msg
type Msg
  = NoMsg

-- event
type Event m
  = Unknown

-- type Event m
--   = Join (Channel.Channel m)
--   | Leave String
--   | Push (Push.Push m)
--   | None

unknown : Event m
unknown = Unknown

-- none : Event m
-- none = None

-- actions
map : (msg -> m) -> Event msg -> Event m
map mapMsg event =
  Unknown

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

snd : Socket m -> Event m -> (Socket m, Cmd (Socket m))
snd sock event =
  (sock, Cmd.none)

-- send : Socket.Socket m -> Event m -> (Socket.Socket m, Cmd (Socket.Msg m))
-- send socket event =
--   case event of
--     Join channel ->
--       Socket.join channel socket
--     Leave name ->
--       Socket.leave name socket
--     Push push ->
--       Socket.push push socket
--     Unknown ->
--       (socket, Cmd.none)

