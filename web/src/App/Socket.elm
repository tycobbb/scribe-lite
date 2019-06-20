port module Socket exposing (MessageOut, Event, send, recv, push, subscribe)

import Json.Encode as JE
import Json.Decode as JD

-- ports --
port send : JE.Value -> Cmd msg
port recv : (JD.Value -> msg) -> Sub msg

-- types --
type alias Event a =
  { name    : String
  , decoder : JD.Decoder a
  }

type alias MessageOut =
  { name : String
  , args : JE.Value
  }

type alias MessageIn v =
  { name : String
  , data : v
  }

-- types/Result
type alias Result a =
  Result.Result Error a

type Error
  = MismatchedEvent
  | DecodeFailed JD.Error

-- impls --
-- impls/push
push : MessageOut -> Cmd msg
push message =
  encodeMessage message
    |> send

-- impls/subscribe
subscribe : (a -> msg) -> msg -> Event a -> Sub msg
subscribe toMsg toIgnore event =
  recv (\data ->
    data
      |> decodeResult event
      |> triggerEvent toMsg toIgnore)

decodeResult : Event a -> JD.Value -> Result a
decodeResult event data =
  data
    |> decodeValue decodeMessage
    |> Result.andThen (selectEvent event.name)
    |> Result.andThen (decodeValue event.decoder)

selectEvent : String -> MessageIn JD.Value -> Result JD.Value
selectEvent name response =
  if response.name == name
    then Ok response.data
    else Err MismatchedEvent

triggerEvent : (a -> msg) -> msg -> Result a -> msg
triggerEvent toMsg toIgnore result =
  case result of
    Ok data ->
      toMsg data
    Err MismatchedEvent ->
      toIgnore
    Err (DecodeFailed error) ->
      Debug.log "Socket.Event" error |> always toIgnore

-- impls/coding
decodeValue : JD.Decoder a -> JD.Value -> Result a
decodeValue decoder value =
  JD.decodeValue decoder value
    |> Result.mapError DecodeFailed

decodeMessage : JD.Decoder (MessageIn JD.Value)
decodeMessage =
  JD.map2 MessageIn
    (JD.field "name" JD.string)
    (JD.field "data" JD.value)

encodeMessage : MessageOut -> JE.Value
encodeMessage message =
  JE.object
    [ ("name", JE.string message.name)
    , ("args", message.args)
    ]
