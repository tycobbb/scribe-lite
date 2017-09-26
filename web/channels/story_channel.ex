defmodule Scribe.StoryChannel do
  use Phoenix.Channel

  def join("story:unified", _message, socket) do
    {:ok, socket}
  end

  def join("story:" <> _story_id, _params, _socket) do
    {:error, %{reason: "not found"}}
  end
end
