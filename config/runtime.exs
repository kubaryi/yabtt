import Elixir.{Config, System, String}

config :yabtt,
  # Set the interval in seconds between each scrape, default to 3600.
  # See: https://wiki.theory.org/BitTorrentSpecification#Tracker_Response
  interval: get_env("YABTT_INTERVAL", "3600") |> to_integer(),
  # How many peers can be returned in one query? default to 50, but we
  # recommend you to set it smaller, like 30. Because this value is
  # important to performance. Practice tells us that even 30 peers is plenty.
  # See: https://wiki.theory.org/BitTorrentSpecification#Tracker_Response
  query_limit: get_env("YABTT_QUERY_LIMIT", "50") |> to_integer(),
  # Force the use of "compact mode", default to false.
  compact_only: get_env("YABTT_COMPACT_ONLY", "false") |> downcase() |> to_existing_atom(),
  # Disable HTTPS, default to false.
  disable_https: get_env("YABTT_DISABLE_HTTPS", "false") |> downcase() |> to_existing_atom()

config :yabtt, YaBTTWeb,
  # Set the port to listen on, default to 8080.
  port: get_env("YABTT_PORT", "8080") |> to_integer()

config :yabtt, YaBTTWeb.Auth,
  # Set the username and password for basic auth, default to "admin" and "admin".
  username: get_env("YABTT_AUTH_USERNAME", "admin"),
  password: get_env("YABTT_AUTH_PASSWORD", "admin")

config :logger,
  # Set the log level, default to :info.
  # See: https://hexdocs.pm/logger/Logger.html#module-levels
  level: get_env("YABTT_LOG_LEVEL", "info") |> to_atom()

if config_env() in [:test, :bench] do
  # Don't print any log in test and benchmark environment.
  config :logger, level: :notice
end
