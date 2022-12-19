defprotocol YaBTT.Proto.Parser do
  @moduledoc """
  Protocol and implementations to parse the unparsed map to a parsed map.
  """

  @type unparsed :: %{String.t() => String.t()}
  @type parsed :: %{atom() => String.t()}
  @type t :: {:ok, parsed()} | :error

  @doc """
  Parse the unparsed map to a parsed map.

  ## Parameters

  - value: The unparsed map to be parsed.

  ## Example

      iex> YaBTT.Proto.Parser.parse(%{
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

      iex> YaBTT.Proto.Parser.parse(%{})
      :error
  """
  @spec parse(unparsed) :: t
  def parse(value)
end

defimpl YaBTT.Proto.Parser, for: Map do
  @moduledoc """
  Implementation of `YaBTT.Proto.Parser` for `Map`.
  """

  alias YaBTT.Proto.Parser

  # The keys that must be integerized.
  @enforce_integerized ["left", "downloaded", "uploaded", "port"]
  # The keys that must be contained in the unparsed map.
  @enforce_keys ["info_hash", "peer_id" | @enforce_integerized]

  @doc """
  Parse the unparsed map to a parsed map.

  ## Parameters

  - value: The unparsed map to be parsed.

  """
  @spec parse(Parser.unparsed()) :: Parser.t()
  def parse(value) do
    if contains_enforce_keys(Map.keys(value)) do
      {:ok, do_parse(value)}
    else
      :error
    end
  end

  @compile {:inline, do_parse: 1}
  @spec do_parse(Parser.unparsed()) :: Parser.parsed()
  defp do_parse(map_with_string_keys) do
    for {k, v} <- map_with_string_keys, into: %{} do
      if k in @enforce_integerized do
        {String.to_atom(k), String.to_integer(v)}
      else
        {String.to_atom(k), v}
      end
    end
  end

  @compile {:inline, contains_enforce_keys: 1}
  @spec contains_enforce_keys([String.t()]) :: boolean()
  defp contains_enforce_keys(keys) do
    Enum.all?(@enforce_keys, &(&1 in keys))
  end
end
