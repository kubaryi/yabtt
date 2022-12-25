defmodule YaBTT.Schema.TorrentTest do
  alias Logger.BackendSupervisor
  use ExUnit.Case, async: true

  doctest YaBTT.Schema.Torrent
  doctest Bento.Encoder.YaBTT.Schema.Torrent
end
