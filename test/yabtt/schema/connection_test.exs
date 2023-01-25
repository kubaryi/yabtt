defmodule YaBTT.Schema.ConnectionTest do
  use ExUnit.Case, async: true

  doctest YaBTT.Schema.Connection

  alias YaBTT.Schema.Connection

  @params_without_event %{
    "uploaded" => "121",
    "downloaded" => "41421",
    "left" => "0"
  }

  @info_hash "00000000000000000000"

  test "changeset with valid event == started" do
    params = Map.put(@params_without_event, "event", "started")
    changeset = Connection.changeset(%Connection{}, params, {@info_hash, 1})

    assert changeset.valid?

    assert changeset.changes == %{
             downloaded: 41421,
             left: 0,
             peer_id: 1,
             torrent_info_hash: @info_hash,
             uploaded: 121,
             started: true
           }
  end

  test "changeset with valid event == stopped" do
    params = Map.put(@params_without_event, "event", "stopped")
    changeset = Connection.changeset(%Connection{}, params, {@info_hash, 1})

    assert changeset.valid?
    assert changeset.changes.started == false
  end

  test "changeset with params without event" do
    changeset = Connection.changeset(%Connection{}, @params_without_event, {@info_hash, 1})

    assert not changeset.valid?
    assert changeset.errors == [started: {"can't be blank", [validation: :required]}]
  end

  test "changeset with valid params but invalid connection" do
    params = Map.put(@params_without_event, "event", "completed")
    changeset = Connection.changeset(%Connection{}, params, {@info_hash, 1})

    assert not changeset.valid?
    assert changeset.errors == [started: {"can't be blank", [validation: :required]}]
  end
end
