defmodule ScribeWeb.UserSocket do
  use Phoenix.Socket

  # channels
  channel "story:*", ScribeWeb.StoryChannel

  # transports
  transport :websocket, Phoenix.Transports.WebSocket

  # callbacks
  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
