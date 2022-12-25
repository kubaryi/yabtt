import Config

# Set the ecto to use the `YaBTT.Repo`.
config :yabtt, ecto_repos: [YaBTT.Repo]
# Set the location of the database, default to `/var/lib/sqlite3/yabtt.db`.
config :yabtt, YaBTT.Repo, database: "/var/lib/sqlite3/yabtt.db"

if config_env() == :dev do
  # Set the location of the database in dev environment.
  config :yabtt, YaBTT.Repo, database: "./_build/data/yabtt.db"
end
