use Mix.Config

# configure application
config :scribe,
  ecto_repos: [Scribe.Repo]

# configure endpoint
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

# configures logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# configure by environment
import_config "#{Mix.env}.exs"
