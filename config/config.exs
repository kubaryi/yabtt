import Config

config :yabtt, YaBTT.Database.Cache,
  ets_name: :cache_ets_bag,
  # if the ETS start with `:set`, you will only get the last peer
  ets_opts: [:bag, :named_table, :protected]
