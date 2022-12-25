import Config

config :yabtt, ecto_repos: [YaBTT.Repo]

config :yabtt, YaBTT.Repo, database: "./_build/data/yabtt.#{config_env()}.db"

if config_env() == :test do
  config :yabtt, YaBTT.Repo,
    database: "./_build/data/yabtt.#{config_env()}.db",
    pool: Ecto.Adapters.SQL.Sandbox
end

if config_env() == :prod do
  config :yabtt, YaBTT.Repo, database: "/var/lib/sqlite3/yabtt.db"
end
