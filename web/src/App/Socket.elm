port module Socket exposing (..)

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

type alias Res a
  = Result ServiceError a

type Error
  = ServiceFailed ServiceError
  | DecodeFailed JD.Error
  | MismatchedEvent

subscribe : (Res a -> msg) -> msg -> Event a -> Sub msg
subscribe toMsg toIgnore event =
  recv (\data ->
    data
      |> decodeEventResult event
      |> messageFromResult toMsg toIgnore)

decodeEventResult : Event a -> JD.Value -> Result Error a
decodeEventResult event data =
  data
    |> decodeValue decodeResponse
    |> Result.andThen (filterEventByName event.name)
    |> Result.andThen (decodeValue event.decoder)

messageFromResult : (Res a -> msg) -> msg -> Result Error a -> msg
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

filterEventByName : String -> Response a -> Result Error a
filterEventByName name response =
  if response.name /= name
    then Err MismatchedEvent
    else response.payload

decodeValue : JD.Decoder a -> JD.Value -> Result Error a
decodeValue decoder value =
  JD.decodeValue decoder value
    |> Result.mapError DecodeFailed

-- event.response
type alias Response v =
  Envelope (Result Error v)

type alias ServiceError =
  { message : String
  }

-- event.response.coding
decodeResponse : JD.Decoder (Response JD.Value)
decodeResponse =
  decodeEnvelope decodePayload

decodePayload : JD.Decoder (Result Error JD.Value)
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
  JD.map (ServiceError >> ServiceFailed)
    (JD.field "message" JD.string)

unknownError : Error
unknownError =
  ServiceFailed (ServiceError "Unknown error.")
