defmodule YaBTT.Schema.AnnounceTest do
  use ExUnit.Case, async: true

  doctest YaBTT.Schema.Announce

  alias YaBTT.Schema.Announce

  @params %{
    "info_hash" => "f0a15e27fafbffc1c2f1",
    "peer_id" => "-TR14276775888084598"
  }

  test "changeset with valid params" do
    changeset = Announce.changeset(%Announce{}, @params)

    assert changeset.valid?

    assert changeset.changes == %{
             info_hash: "f0a15e27fafbffc1c2f1",
             peer_id: "-TR14276775888084598"
           }
  end

  test "changeset with no_peer_id == 1 & compact == 1" do
    params = Map.merge(@params, %{"no_peer_id" => "1", "compact" => "1"})
    changeset = Announce.changeset(%Announce{}, params)

    assert changeset.valid?

    assert changeset.changes == %{
             info_hash: "f0a15e27fafbffc1c2f1",
             peer_id: "-TR14276775888084598",
             no_peer_id: 1,
             compact: 1
           }
  end

  test "changeset with env YABTT_COMPACT_ONLY == true" do
    Application.put_env(:yabtt, :compact_only, true)
    changeset = Announce.changeset(%Announce{}, @params)

    assert changeset.valid?
    assert changeset.changes.compact == 1

    Application.delete_env(:yabtt, :compact_only)
  end

  test "changeset with env YABTT_COMPACT_ONLY == true & compact == 0" do
    Application.put_env(:yabtt, :compact_only, true)
    params = Map.merge(@params, %{"compact" => "0"})
    changeset = Announce.changeset(%Announce{}, params)

    refute changeset.valid?

    assert changeset.errors == [
             compact: {"connection refused", [validation: :compact]}
           ]

    Application.delete_env(:yabtt, :compact_only)
  end

  test "changeset with invalid params" do
    changeset = Announce.changeset(%Announce{}, %{})

    refute changeset.valid?

    assert changeset.errors == [
             info_hash: {"can't be blank", [validation: :required]},
             peer_id: {"can't be blank", [validation: :required]}
           ]
  end

  test "apply with valid params" do
    assert {:ok, %Announce{}} = Announce.apply(@params)
  end

  test "apply with invalid params" do
    assert {:error, %Ecto.Changeset{}} = Announce.apply(%{})
  end
end
