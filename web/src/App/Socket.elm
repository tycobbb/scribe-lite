port module Socket exposing (Message, Event, Result, send, recv, push, subscribe)

import Json.Encode as JE
import Json.Decode as JD

-- ports
port send : JE.Value -> Cmd msg
port recv : (JD.Value -> msg) -> Sub msg

-- envelope
type alias Envelope p =
  { name    : String
  , payload : p
  }

-- envelope.coding
encodeEnvelope : Envelope JE.Value -> JE.Value
encodeEnvelope envelope =
  JE.object
    [ ("name",   JE.string envelope.name)
    , ("params", envelope.payload)
    ]

decodeEnvelope : JD.Decoder p -> JD.Decoder (Envelope p)
decodeEnvelope decodeP =
  JD.map2 Envelope
    (JD.field "name" JD.string)
    (decodeP)

-- message (push)
type alias Message =
  { name : String
  , data : JE.Value
  }

push : Message -> Cmd msg
push message =
  Envelope message.name message.data
    |> encodeEnvelope
    |> send

-- event (subscribe)
type alias Event a =
  { name    : String
  , decoder : JD.Decoder a
  }

type alias EventResult a
  = Result.Result EventError a

type EventError
  = ServiceFailed ServiceError
  | DecodeFailed JD.Error
  | MismatchedEvent

subscribe : (Result a -> msg) -> msg -> Event a -> Sub msg
subscribe toMsg toIgnore event =
  recv (\data ->
    data
      |> decodeEventResult event
      |> messageFromResult toMsg toIgnore)

decodeEventResult : Event a -> JD.Value -> EventResult a
decodeEventResult event data =
  data
    |> decodeEventValue decodeResponse
    |> Result.andThen (selectEventResult event.name)
    |> Result.andThen (decodeEventValue event.decoder)

selectEventResult : String -> Response a -> EventResult a
selectEventResult name response =
  if response.name /= name then
    Err MismatchedEvent
  else
    response.payload
      |> Result.mapError ServiceFailed

decodeEventValue : JD.Decoder a -> JD.Value -> EventResult a
decodeEventValue decoder value =
  JD.decodeValue decoder value
    |> Result.mapError DecodeFailed

messageFromResult : (Result a -> msg) -> msg -> EventResult a -> msg
messageFromResult toMsg toIgnore result =
  case result of
    Ok data ->
      toMsg (Ok data)
    Err (ServiceFailed error) ->
      toMsg (Err error)
    Err (DecodeFailed error) ->
      Debug.log "Socket.Event" error
        |> always toIgnore
    Err MismatchedEvent ->
      toIgnore

-- event.response
type alias Response v =
  Envelope (Result v)

type alias Result a
  = Result.Result ServiceError a

type alias ServiceError =
  { message : String
  }

-- event.response.coding
decodeResponse : JD.Decoder (Response JD.Value)
decodeResponse =
  decodeEnvelope decodePayload

decodePayload : JD.Decoder (Result JD.Value)
decodePayload =
  JD.map2 decodeResult
    (JD.maybe (JD.field "error" decodeError))
    (JD.maybe (JD.field "data"  JD.value))

decodeResult : Maybe ServiceError -> Maybe JD.Value -> Result JD.Value
decodeResult error data =
  data
    |> Result.fromMaybe error
    |> Result.mapError (Maybe.withDefault unknownError)

decodeError : JD.Decoder ServiceError
decodeError =
  JD.map ServiceError
    (JD.field "message" JD.string)

unknownError : ServiceError
unknownError =
  ServiceError "Unknown error."
