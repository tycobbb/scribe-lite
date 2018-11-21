defmodule ScribeWeb.StoryChannelTest do
  use ScribeWeb.ChannelCase

  alias Scribe.Line

  def join do
    socket()
      |> subscribe_and_join(ScribeWeb.StoryChannel, "story:unified")
  end

  describe "#join/3" do
    test "story:unified responds with the last line" do
      other_attrs = %{
        text: "join/3 first line",
        email: "test@email.com",
        name: "test name"
      }

      %Line{}
        |> Line.changeset(other_attrs)
        |> Repo.insert()

      attrs = %{
        text: "join/3 last line",
        email: "test@email.com",
        name: "test name"
      }

      %Line{}
        |> Line.changeset(attrs)
        |> Repo.insert()

      {_, response, _} = join()

      assert(response == Map.take(attrs, [:text, :name]))
    end

    test "story:unified responds with nil when there is no line" do
      {_, response, _} = join()
      assert(response == nil)
    end
  end

  describe "#handle_in/3" do
    setup do
      {:ok, _, socket} = join()
      {:ok, socket: socket}
    end

    test "add:line inserts a new line", %{socket: socket} do
      attrs = %{
        text: "handle_in/3 test line",
        email: "test@email.com",
        name: "test name"
      }

      ref = push(socket, "add:line", %{
        "text" => attrs.text,
        "email" => attrs.email,
        "name" => attrs.name
      })

      assert_reply(ref, :ok)
      assert attrs == Line
        |> first
        |> Repo.one
        |> Map.take(Map.keys(attrs))
    end
  end
end
