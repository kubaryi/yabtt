defmodule YaBTT.Schema.TorrentTest do
  use ExUnit.Case, async: true

  doctest YaBTT.Schema.Torrent

  alias YaBTT.Schema.Torrent

  @params %{
    "info_hash" =>
      <<18, 52, 86, 120, 154, 188, 222, 241, 35, 69, 103, 137, 171, 205, 239, 18, 52, 86, 12, 15>>
  }

  test "changeset with valid params" do
    changeset = Torrent.changeset(%Torrent{}, @params)

    assert changeset.valid?
    assert changeset.changes == %{info_hash: @params["info_hash"]}
  end

  test "changeset with invalid params" do
    changeset = Torrent.changeset(%Torrent{}, %{})

    refute changeset.valid?
    assert changeset.errors == [info_hash: {"can't be blank", [validation: :required]}]
  end
end
