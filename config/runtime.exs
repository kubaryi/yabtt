import Config

config :yabtt, cowboy_port: System.get_env("YABTT_PORT", "8080") |> String.to_integer()
