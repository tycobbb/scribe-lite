defmodule Scribe.StoryChannel do
  use Phoenix.Channel, log_join: true, log_handle_in: true

  alias Scribe.Repo
  alias Scribe.Line

  def join("story:" <> _id, _params, socket) do
    response = %{
      prompt: "When the tiny dumpling decided to jump across the river, it let out a sigh.",
      author: "Gob Bluth"
    }

    {:ok, response, socket}
  end

  def handle_in("add:line", %{"text" => text, "email" => email}, socket) do
    result = %Line{}
      |> Line.changeset(%{text: text, email: email})
      |> Repo.insert()

    case result do
      {:ok, _} ->
        {:reply, :ok, socket}
      {:error, _} ->
        {:reply, :error, socket}
    end
  end
end
