defmodule YaBTT.Schema.PeerTest do
  use ExUnit.Case, async: true

  doctest YaBTT.Schema.Peer

  alias YaBTT.Schema.Peer

  @params %{
    "peer_id" => "-TR14276775888084598",
    "port" => "6881"
  }

  test "changeset with valid params" do
    changeset = Peer.changeset(%Peer{}, @params, {1, 2, 3, 4})

    assert changeset.valid?

    assert changeset.changes == %{
             peer_id: "-TR14276775888084598",
             ip: {1, 2, 3, 4},
             port: 6881
           }
  end

  test "changeset with explicit IP" do
    params = Map.put(@params, "ip", "127.0.0.1")
    changeset = Peer.changeset(%Peer{}, params, {1, 2, 3, 4})

    assert changeset.valid?

    assert changeset.changes == %{
             peer_id: "-TR14276775888084598",
             ip: {127, 0, 0, 1},
             port: 6881
           }
  end

  test "changeset with IPv6" do
    params = Map.put(@params, "ip", "::1")
    changeset = Peer.changeset(%Peer{}, params, {1, 2, 3, 4})

    assert changeset.valid?

    assert changeset.changes == %{
             peer_id: "-TR14276775888084598",
             ip: {0, 0, 0, 0, 0, 0, 0, 1},
             port: 6881
           }
  end

  test "changeset with invalid params" do
    changeset = Peer.changeset(%Peer{}, %{}, {1, 2, 3, 4})

    assert not changeset.valid?

    assert changeset.errors == [
             peer_id: {"can't be blank", [validation: :required]},
             port: {"can't be blank", [validation: :required]}
           ]
  end

  test "changeset with invalid ip" do
    changeset = Peer.changeset(%Peer{}, @params, {1, 2, 3, 4, 5})

    assert not changeset.valid?

    assert changeset.errors == [
             ip: {"is invalid", [{:type, YaBTT.CustomTypes.IPAddress}, {:validation, :cast}]}
           ]
  end
end
