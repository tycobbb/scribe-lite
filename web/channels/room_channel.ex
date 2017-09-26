defmodule HelloWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:story", _message, socket) do
    {:ok, socket}
  end
end
