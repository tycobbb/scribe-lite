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
  recv (\data -> data |> (JD.decodeValue decodeResponse) |> Debug.log "listen" |> (\_ -> toMsg NoMsg))

-- envelope
type alias Envelope p =
  { name    : String
  , payload : p
  }

-- envelope.coding
encodeEnvelope : Envelope JE.Value -> JE.Value
encodeEnvelope envelope =
  JE.object
    [ ("name", JE.string envelope.name)
    , ("data", envelope.payload)
    ]

decodeEnvelope : JD.Decoder p -> JD.Decoder (Envelope p)
decodeEnvelope decodeP =
  JD.map2 Envelope
    (JD.field "name" JD.string)
    (decodeP)

-- message
type alias Message =
  { name : String
  , data : JE.Value
  }

push : Message -> Cmd msg
push message =
  Envelope message.name message.data
    |> encodeEnvelope
    |> send

-- event
type alias Evt a =
  { name    : String
  , decoder : JD.Decoder a
  }

type Error
  = DecodingError JD.Error
  | ResponseError ServiceError
  | MismatchedEvent

subscribe : (Result Error a -> msg) -> Evt a -> Sub msg
subscribe toMsg event =
  recv (\data ->
    data
      |> decodeEventResponse event
      |> toMsg)

decodeEventResponse : Evt a -> JD.Value -> Payload a
decodeEventResponse event data =
  data
    |> decodeValue decodeResponse
    |> Result.andThen (filteredToEvent event.name)
    |> Result.andThen (decodeValue event.decoder)

decodeValue : JD.Decoder a -> JD.Value -> Result Error a
decodeValue decoder value =
  JD.decodeValue decoder value
    |> Result.mapError DecodingError

filteredToEvent : String -> Response a -> Payload a
filteredToEvent name response =
  if response.name /= name
    then Err MismatchedEvent
    else response.payload

-- event.response
type alias Response v =
  Envelope (Payload v)

type alias Payload v =
  Result Error v

type alias ServiceError =
  { message : String
  }

-- event.response.coding
decodeResponse : JD.Decoder (Response JD.Value)
decodeResponse =
  decodeEnvelope decodePayload

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
      (JD.maybe (JD.field "data"  JD.value))

decodeError : JD.Decoder Error
decodeError =
  JD.map (ServiceError >> ResponseError)
    (JD.field "message" JD.string)

unknownError : Error
unknownError =
  ResponseError (ServiceError "Unknown error.")

-- event
type Msg
  = NoMsg

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

