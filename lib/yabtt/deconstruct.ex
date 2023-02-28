defmodule YaBTT.Deco do
  @moduledoc """
  To store the deconstruct of the announce request parameters.
  """

  defstruct ids: %{info_hash: nil, peer_id: nil, key: nil},
            config: %{mode: nil, query_limit: 50},
            params: nil

  @type config :: %{mode: :compact | :normal | nil, query_limit: integer()}
  @type ids :: %{info_hash: binary(), peer_id: binary(), key: binary() | nil}
  @type t :: %__MODULE__{ids: ids(), config: config(), params: map() | nil}
end

defmodule YaBTT.Deconstruct do
  @moduledoc """
  To deconstruct the announce request parameters.
  """

  @doc """
  Deconstruct the announce request parameters.

  The `params` can be a `t:map/0` or a `t:Keyword.t/0`. If it is a Keyword, it will be converted to
  a map first. The `params` must contain the `info_hash` and `peer_id` keys. Otherwise, it will
  return an error. The `params` will be stored in the `t:YaBTT.Deco.t/0` struct.
  """
  @spec deco(term()) :: {:error, String.t()} | {:ok, YaBTT.Deco.t()}
  def deco(kv) when is_map(kv) do
    with {:ok, struct} <- ids(%YaBTT.Deco{}, kv) do
      {:ok, struct |> params(kv) |> config(kv)}
    end
  end

  def deco(kv) when is_list(kv), do: deco(Map.new(kv))
  def deco(_), do: {:error, "invalid params"}

  defp ids(struct, %{"info_hash" => _, "peer_id" => _} = params) do
    {:ok, %{struct | ids: do_ids(struct.ids, params)}}
  end

  defp ids(_struct, _) do
    {:error, "info_hash and peer_id are required"}
  end

  defp do_ids(ids, params) do
    Enum.reduce(ids, %{}, fn {key, value}, map ->
      Map.put(map, key, Map.get(params, to_string(key), value))
    end)
  end

  defp params(struct, params), do: %{struct | params: params}

  defp config(struct, params) do
    %{struct | config: struct.config |> mode(params) |> query_limit(params)}
  end

  defp mode(config, params) do
    case params do
      %{"compact" => "1"} -> %{config | mode: :compact}
      %{"no_peer_id" => "1"} -> %{config | mode: :no_peer_id}
      _ -> config
    end
  end

  defp query_limit(config, params) do
    default = Application.get_env(:yabtt, :query_limit, 50)

    limit =
      with %{"num_want" => num_want} <- params,
           {num_want, ""} <- Integer.parse(num_want) do
        Enum.min([num_want, default])
      else
        _ -> default
      end

    %{config | query_limit: limit}
  end
end
