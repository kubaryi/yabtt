import Config

config :yabtt, ecto_repos: [YaBTT.Repo]

config :yabtt, YaBTT.Repo, database: "./_build/#{config_env()}/yabtt.db"

if config_env() == :test do
  config :yabtt, YaBTT.Repo, pool: Ecto.Adapters.SQL.Sandbox
end

if config_env() == :prod do
  config :yabtt, YaBTT.Repo, database: "/var/lib/sqlite3/yabtt.db"
end
