defmodule YaBTT.FrontTest do
  use ExUnit.Case, async: true

  alias YaBTT.Front

  @params %{
    "info_hash" => "f0a15e27fafbffc1c2f1",
    "peer_id" => "-TR14276775888084598"
  }

  test "Create %Front{} with valid params" do
    assert {:ok, front} = Front.new(@params)

    %{"info_hash" => info_hash, "peer_id" => peer_id} = @params

    assert %Front{
             ids: %{info_hash: info_hash, peer_id: peer_id, key: nil},
             params: @params
           } == front
  end

  test "Create %Front{} with invalid params" do
    assert {:error, _} = Front.new(%{})
    assert {:error, _} = Front.new("invalid")
  end

  test "Create %Front{} with Keyword" do
    assert {:ok, _} = Front.new(@params |> Map.to_list())
  end

  test "Create %Front{} with key" do
    params = Map.merge(@params, %{"key" => "qfu17s"})
    assert {:ok, %{ids: %{key: "qfu17s"}}} = Front.new(params)
  end

  test "Create %Front{} with compact mode" do
    params = Map.merge(@params, %{"no_peer_id" => "1", "compact" => "1"})
    assert {:ok, %{config: %{mode: :compact}}} = Front.new(params)

    params = Map.merge(@params, %{"no_peer_id" => "1", "compact" => "0"})
    assert {:ok, %{config: %{mode: :no_peer_id}}} = Front.new(params)
  end

  test "Create %Front{} with num_want" do
    params = Map.merge(@params, %{"num_want" => "40"})
    assert {:ok, %{config: %{query_limit: 40}}} = Front.new(params)

    Application.put_env(:yabtt, :query_limit, 30)
    assert {:ok, %{config: %{query_limit: 30}}} = Front.new(params)
    Application.delete_env(:yabtt, :query_limit)
  end
end
