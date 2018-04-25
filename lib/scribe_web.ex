defmodule Scribe.Web do
  def model do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: ScribeWeb

      import Ecto
      import Ecto.Query
      import ScribeWeb.Router.Helpers
      import ScribeWeb.Gettext

      alias ScribeWeb.Repo
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/scribe_web/templates",
        namespace: ScribeWeb

      # import convenience functions from controllers
      import Phoenix.Controller,
        only: [
          get_csrf_token: 0,
          get_flash: 2,
          view_module: 1
        ]

      # use all html functionality (forms, tags, etc)
      use Phoenix.HTML

      import ScribeWeb.Router.Helpers
      import ScribeWeb.ErrorHelpers
      import ScribeWeb.Gettext
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias Scribe.Repo

      import Ecto
      import Ecto.Query
      import ScribeWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
