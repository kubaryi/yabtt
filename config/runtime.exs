import System, only: [get_env: 1, get_env: 2]
import String, only: [to_integer: 1, to_atom: 1, to_existing_atom: 1]
import Config

config :yabtt,
  # Set the interval in seconds between each scrape, default to 3600.
  # See: https://wiki.theory.org/BitTorrentSpecification#Tracker_Response
  interval: get_env("YABTT_INTERVAL", "3600") |> to_integer(),
  # Set the port to listen on, default to 8080.
  port: get_env("YABTT_PORT", "8080") |> to_integer()

config :logger,
  # Set the log level, default to :info.
  # See: https://hexdocs.pm/logger/Logger.html#module-levels
  level: get_env("YABTT_LOG_LEVEL", "info") |> to_atom(),
  # Print the UTC time in the log, default to true.
  utc_log: get_env("YABTT_UTC_LOG", "true") |> to_existing_atom()
