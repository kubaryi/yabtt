defprotocol YaBTT.Proto.Norm do
  @moduledoc """
  Protocol and implementations to normalize the unnormalized map to a normalized map.
  """

  @type unnormalized :: %{String.t() => String.t()}
  @type normalized :: %{atom() => String.t()}
  @type t :: {:ok, normalized()} | :error

  @doc """
  Normalize the unnormalized map to a normalized map.

  ## Parameters

  - value: The unnormalized map to be normalized.

  ## Example

      iex> YaBTT.Proto.Norm.normalize(%{
      ...>   "info_hash" => "info_hash",
      ...>   "peer_id" => "peer_id",
      ...>   "left" => "0",
      ...>   "downloaded" => "100",
      ...>   "uploaded" => "0",
      ...>   "port" => "6881"
      ...> })
      {:ok,
        %{info_hash: "info_hash",
          peer_id: "peer_id",
          left: 0,
          downloaded: 100,
          uploaded: 0,
          port: 6881
        }
      }

      iex> YaBTT.Proto.Norm.normalize(%{})
      :error
  """
  @spec normalize(unnormalized) :: t
  def normalize(value)
end

defimpl YaBTT.Proto.Norm, for: Map do
  @moduledoc """
  Implementation of `YaBTT.Proto.Norm` for `Map`.
  """

  alias YaBTT.Proto.Norm

  # The keys that must be integerized.
  @enforce_integerized ["left", "downloaded", "uploaded", "port"]
  # The keys that must be contained in the unnormalized map.
  @enforce_keys ["info_hash", "peer_id" | @enforce_integerized]

  @doc """
  Normalize the unnormalized map to a normalized map.

  ## Parameters

  - value: The unnormalized map to be normalized.

  """
  @spec normalize(Norm.unnormalized()) :: Norm.t()
  def normalize(value) do
    if contains_enforce_keys(Map.keys(value)) do
      {:ok, do_normalize(value)}
    else
      :error
    end
  end

  @spec do_normalize(Norm.unnormalized()) :: Norm.normalized()
  defp do_normalize(map_with_string_keys) do
    for {k, v} <- map_with_string_keys, into: %{} do
      if k in @enforce_integerized do
        {String.to_atom(k), String.to_integer(v)}
      else
        {String.to_atom(k), v}
      end
    end
  end

  @spec contains_enforce_keys([String.t()]) :: boolean()
  defp contains_enforce_keys(keys) do
    Enum.all?(@enforce_keys, &(&1 in keys))
  end
end
