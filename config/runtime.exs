import Elixir.{Config, System, String}

config :yabtt,
  # Set the interval in seconds between each scrape, default to 3600.
  # See: https://wiki.theory.org/BitTorrentSpecification#Tracker_Response
  interval: get_env("YABTT_INTERVAL", "3600") |> to_integer(),
  # Set the port to listen on, default to 8080.
  port: get_env("YABTT_PORT", "8080") |> to_integer()

config :yabtt, YaBTT.Repo,
  # Set the databse name, default to yabtt_repo.
  database: get_env("POSTGRES_DB", "yabtt_repo"),
  # Set the database username, default to postgres.
  username: get_env("POSTGRES_USER", "postgres"),
  # Set the database password, default to passwd.
  password: get_env("POSTGRES_PASSWORD", "passwd"),
  # Set the database hostname, default to localhost.
  hostname: get_env("POSTGRES_HOST", "localhost")

config :logger,
  # Set the log level, default to :info.
  # See: https://hexdocs.pm/logger/Logger.html#module-levels
  level: get_env("YABTT_LOG_LEVEL", "info") |> to_atom()

if config_env() == :test do
  # Set the log level to :notice in test environment.
  config :logger, level: :notice
end
