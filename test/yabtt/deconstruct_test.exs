defmodule YaBTT.DeconstructTest do
  use ExUnit.Case, async: true

  alias YaBTT.{Dec, Deconstruct}

  @params %{
    "info_hash" => "f0a15e27fafbffc1c2f1",
    "peer_id" => "-TR14276775888084598"
  }

  test "Create %Deconstruct{} with valid params" do
    assert {:ok, dec} = Deconstruct.dec(@params)

    %{"info_hash" => info_hash, "peer_id" => peer_id} = @params

    assert %Dec{
             ids: %{info_hash: info_hash, peer_id: peer_id, key: nil},
             params: @params
           } == dec
  end

  test "Create %Deconstruct{} with invalid params" do
    assert {:error, _} = Deconstruct.dec(%{})
    assert {:error, _} = Deconstruct.dec("invalid")
  end

  test "Create %Deconstruct{} with Keyword" do
    assert {:ok, _} = Deconstruct.dec(@params |> Map.to_list())
  end

  test "Create %Deconstruct{} with key" do
    params = Map.merge(@params, %{"key" => "qfu17s"})
    assert {:ok, %{ids: %{key: "qfu17s"}}} = Deconstruct.dec(params)
  end

  test "Create %Deconstruct{} with compact mode" do
    params = Map.merge(@params, %{"no_peer_id" => "1", "compact" => "1"})
    assert {:ok, %{config: %{mode: :compact}}} = Deconstruct.dec(params)

    params = Map.merge(@params, %{"no_peer_id" => "1", "compact" => "0"})
    assert {:ok, %{config: %{mode: :no_peer_id}}} = Deconstruct.dec(params)
  end

  test "Create %Deconstruct{} with num_want" do
    params = Map.merge(@params, %{"num_want" => "40"})
    assert {:ok, %{config: %{query_limit: 40}}} = Deconstruct.dec(params)

    Application.put_env(:yabtt, :query_limit, 30)
    assert {:ok, %{config: %{query_limit: 30}}} = Deconstruct.dec(params)
    Application.delete_env(:yabtt, :query_limit)
  end
end
