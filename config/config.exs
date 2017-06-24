use Mix.Config

# general application configuration
config :scribe,
  ecto_repos: [Scribe.Repo]

# configures the endpoint
config :scribe, Scribe.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "eiUHlp7TGDdi1WHFuhl66clhniPfQAkpYpucp9nDP8K5mHaT5vKJ2WHO9bNwnH1D",
  render_errors: [
    view: Scribe.ErrorView,
    accepts: ~w(html json)
  ],
  pubsub: [
    name: Scribe.PubSub,
    adapter: Phoenix.PubSub.PG2
  ]

# configures elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# import environment specific config.
import_config "#{Mix.env}.exs"
