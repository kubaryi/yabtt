import Config

config :yabtt, YaBTT.Database.Cache,
  # The name for the cache table (ETC), default to :yabtt_database_cache
  ets_name: :yabtt_database_cache,
  # The options for the cache table (ETC), default to [:bag, :named_table, :protected]
  # If the ETS start with `:set`, you will only get the last peer.
  ets_opts: [:bag, :named_table, :protected]
