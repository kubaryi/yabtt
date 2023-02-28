defmodule YaBTT.DeconstructTest do
  use ExUnit.Case, async: true

  alias YaBTT.{Deco, Deconstruct}

  @params %{
    "info_hash" => "f0a15e27fafbffc1c2f1",
    "peer_id" => "-TR14276775888084598"
  }

  test "Create %Deconstruct{} with valid params" do
    assert {:ok, deco} = Deconstruct.deco(@params)

    %{"info_hash" => info_hash, "peer_id" => peer_id} = @params

    assert %Deco{
             ids: %{info_hash: info_hash, peer_id: peer_id, key: nil},
             params: @params
           } == deco
  end

  test "Create %Deconstruct{} with invalid params" do
    assert {:error, _} = Deconstruct.deco(%{})
    assert {:error, _} = Deconstruct.deco("invalid")
  end

  test "Create %Deconstruct{} with Keyword" do
    assert {:ok, _} = Deconstruct.deco(@params |> Map.to_list())
  end

  test "Create %Deconstruct{} with key" do
    params = Map.merge(@params, %{"key" => "qfu17s"})
    assert {:ok, %{ids: %{key: "qfu17s"}}} = Deconstruct.deco(params)
  end

  test "Create %Deconstruct{} with compact mode" do
    params = Map.merge(@params, %{"no_peer_id" => "1", "compact" => "1"})
    assert {:ok, %{config: %{mode: :compact}}} = Deconstruct.deco(params)

    params = Map.merge(@params, %{"no_peer_id" => "1", "compact" => "0"})
    assert {:ok, %{config: %{mode: :no_peer_id}}} = Deconstruct.deco(params)
  end

  test "Create %Deconstruct{} with num_want" do
    params = Map.merge(@params, %{"num_want" => "40"})
    assert {:ok, %{config: %{query_limit: 40}}} = Deconstruct.deco(params)

    Application.put_env(:yabtt, :query_limit, 30)
    assert {:ok, %{config: %{query_limit: 30}}} = Deconstruct.deco(params)
    Application.delete_env(:yabtt, :query_limit)
  end
end
