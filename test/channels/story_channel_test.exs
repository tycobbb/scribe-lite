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

    test "add:line replies with status ok", %{socket: socket} do
      ref = push(socket, "add:line", %{"hello" => "there"})
      assert_reply(ref, :ok)
    end
  end
end
