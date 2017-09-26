defmodule Scribe.UserSocket do
  use Phoenix.Socket

  # channels
  channel "room:*", Scribe.RoomChannel

  # transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
