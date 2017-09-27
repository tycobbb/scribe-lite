defmodule Scribe.StoryChannel do
  use Phoenix.Channel

  def join("story:unified", _message, socket) do
    response = %{
      prompt: "When the tiny dumpling decided to jump across the river, it let out a sigh.",
      author: "Gob Bluth"
    }

    {:ok, response, socket}
  end

  def join("story:" <> _story_id, _params, _socket) do
    {:error, %{reason: "not found"}}
  end
end
