require IEx

defmodule Scribe.StoryChannelTest do
  use Scribe.ChannelCase

  def join do
    socket()
      |> subscribe_and_join(Scribe.StoryChannel, "story:unified")
  end

  describe "#join/3" do
    test "story:unified responds with the story data" do
      {_, response, _ } = join()

      assert(response == %{
        prompt: "When the tiny dumpling decided to jump across the river, it let out a sigh.",
        author: "Gob Bluth"
      })
    end
  end

  describe "#handle_in/3" do
    setup do
      {:ok, _, socket} = join()
      {:ok, socket: socket}
    end

    test "add:line inserts a new line", %{socket: socket} do
      line = %{
        text: "test line",
        email: "test@email.com"
      }

      ref = push(socket, "add:line", %{
        "text" => line.text,
        "email" => line.email
      })

      assert_reply(ref, :ok)
      assert line == Scribe.Line |> first |> Repo.one |> Map.take(Map.keys(line))
    end
  end
end
