defmodule Scribe.UserSocket do
  use Phoenix.Socket

  # channels
  channel "story:*", Scribe.StoryChannel

  # transports
  transport :websocket, Phoenix.Transports.WebSocket

  # callbacks
  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
