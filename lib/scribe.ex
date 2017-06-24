defmodule Scribe do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      # start the Ecto repository
      supervisor(Scribe.Repo, []),
      # start the endpoint when the application starts
      supervisor(Scribe.Endpoint, []),
    ]

    opts = [
      strategy: :one_for_one,
      name: Scribe.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Scribe.Endpoint.config_change(changed, removed)
    :ok
  end
end
