defmodule Scribe.StoryChannel do
  use Phoenix.Channel, log_join: true, log_handle_in: true

  def join("story:" <> _id, _params, socket) do
    response = %{
      prompt: "When the tiny dumpling decided to jump across the river, it let out a sigh.",
      author: "Gob Bluth"
    }

    {:ok, response, socket}
  end

  def handle_in("add:line", _message, socket) do
    {:noreply, socket}
  end
end
