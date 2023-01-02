import Config

config :yabtt, ecto_repos: [YaBTT.Repo]

config :yabtt, YaBTT.Repo, database: "./_build/#{config_env()}/yabtt.db"

config :yabtt, Plug.Cowboy,
  scheme: :https,
  certfile: "priv/cert/selfsigned.pem",
  keyfile: "priv/cert/selfsigned_key.pem",
  cipher_suite: :strong,
  otp_app: :yabtt

if config_env() == :test do
  config :yabtt, YaBTT.Repo, pool: Ecto.Adapters.SQL.Sandbox
end

if config_env() == :prod do
  config :yabtt, YaBTT.Repo, database: "/var/lib/sqlite3/yabtt.db"

  config :yabtt, Plug.Cowboy,
    certfile: "/etc/yabtt/ssl/cert.pem",
    keyfile: "/etc/yabtt/ssl/privkey.pem",
    cacertfile: "/etc/yabtt/ssl/chain.pem"
end
