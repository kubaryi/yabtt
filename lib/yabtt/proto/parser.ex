defprotocol YaBTT.Proto.Parser do
  @moduledoc """
  Protocol and implementations to parse the unparsed map to a parsed map.
  """

  @type unparsed :: %{String.t() => String.t()}
  @type parsed :: %{atom() => String.t()}
  @type error :: {:error, Strinh.t()}
  @type t :: {:ok, parsed()} | error() | unparsed()

  @doc """
  Parse the unparsed map to a parsed map. Parse the struct to an unparsed map.

  ## Parameters

  - value: The unparsed map or struct to be parsed.

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

  If the unparsed map does not contain the keys that must be contained,
  it will return an `{:error, _}`.

      iex> YaBTT.Proto.Parser.parse(%{})
      {:error, "invalid requeste"}

  If the struct is passed, it will return an unparsed map.

      iex> %YaBTT.Proto.Peered{peer_id: "peer_id",ip: {1, 2, 3, 4}, port: 6881}
      ...> |> YaBTT.Proto.Parser.parse()
      %{"port" => 6881, "ip" => {1, 2, 3, 4}, "peer id" => "peer_id"}

      iex> %YaBTT.Proto.Response{interval: 1800, peers: []}
      ...> |> YaBTT.Proto.Parser.parse()
      %{"interval" => 1800, "peers" => []}
  """
  @spec parse(unparsed() | struct()) :: t()
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
      {:error, "invalid requeste"}
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

defimpl YaBTT.Proto.Parser, for: [YaBTT.Proto.Peered, YaBTT.Proto.Response] do
  @moduledoc """
  Implementation of `YaBTT.Proto.Parser` for `YaBTT.Proto.Peered` and `YaBTT.Proto.Response`.
  """

  alias YaBTT.Proto.{Parser, Peered, Response}

  @type parsable :: Peered.t() | Response.t()

  @doc """
  Parse the struct to an unparsed map.

  ## Parameters

  - parsable: The struct to be parsed.

  ## Example

      iex> %YaBTT.Proto.Peered{peer_id: "peer_id",ip: {1, 2, 3, 4}, port: 6881}
      ...> |> YaBTT.Proto.Parser.parse()
      %{"port" => 6881, "ip" => {1, 2, 3, 4}, "peer id" => "peer_id"}

      iex> %YaBTT.Proto.Response{interval: 1800, peers: []}
      ...> |> YaBTT.Proto.Parser.parse()
      %{"interval" => 1800, "peers" => []}
  """
  @spec parse(parsable()) :: Parser.unparsed()
  def parse(parsable) do
    Map.from_struct(parsable) |> do_parse()
  end

  @compile {:inline, do_parse: 1}
  @spec do_parse(Parser.parsed()) :: Parser.unparsed()
  defp do_parse(map_with_atom_keys) do
    for {k, v} <- map_with_atom_keys, into: %{} do
      {Atom.to_string(k) |> String.replace("_", " "), v}
    end
  end
end
