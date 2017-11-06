defmodule Scribe.StoryChannel do
  use Phoenix.Channel, log_join: true, log_handle_in: true
  require Ecto.Query

  alias Scribe.Repo
  alias Scribe.Line

  def join("story:" <> _id, _params, socket) do
    line = Line
      |> Ecto.Query.last
      |> Ecto.Query.select([l], map(l, [:text, :name]))
      |> Repo.one

    {:ok, line, socket}
  end

  def handle_in("add:line", %{"text" => _, "email" => _, "name" => _} = attrs, socket) do
    result = %Line{}
      |> Line.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, _} ->
        {:reply, :ok, socket}
      {:error, _} ->
        {:reply, :error, socket}
    end
  end
end
