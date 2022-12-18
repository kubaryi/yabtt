import System, only: [get_env: 1, get_env: 2]
import String, only: [to_integer: 1]
import Config

config :yabtt,
  interval: get_env("YABTT_INTERVAL", "3600") |> to_integer(),
  port: get_env("YABTT_PORT", "8080") |> to_integer()
