import Config

config :yabtt, ecto_repos: [YaBTT.Repo]

config :yabtt, YaBTT.Database.Cache,
  # Enable the cache, default to true
  # This is our only database endpoint at present, so don't disable it.
  enable: true,
  # The name for the cache table (ETC), default to :yabtt_database_cache
  ets_name: :yabtt_database_cache,
  # The options for the cache table (ETC), default to [:bag, :named_table, :protected]
  # If the ETS start with `:set`, you will only get the last peer.
  ets_opts: [:bag, :named_table, :protected]
