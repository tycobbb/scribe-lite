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
    [ ("name", JE.string envelope.name)
    , ("data", envelope.payload)
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
      |> decodeEventPayload event
      |> toMsg)

decodeEventPayload : Evt a -> JD.Value -> Payload a
decodeEventPayload event data =
  data
    |> decodeValue decodeResponse
    |> Result.andThen (filterEventByName event.name)
    |> Result.andThen (decodeValue event.decoder)

decodeValue : JD.Decoder a -> JD.Value -> Result Error a
decodeValue decoder value =
  JD.decodeValue decoder value
    |> Result.mapError DecodingError

filterEventByName : String -> Response a -> Payload a
filterEventByName name response =
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
