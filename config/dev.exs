use Mix.Config

# for development, we disable any cache and enable debugging and code reloading.
config :scribe, Scribe.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [npm: ["run", "watch"]]

# catch static and templates for browser reloading.
config :scribe, Scribe.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# set a higher stacktrace during development.
config :phoenix, :stacktrace_depth, 20

# configure your database
config :scribe, Scribe.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "scribe_dev",
  hostname: "localhost",
  pool_size: 10
