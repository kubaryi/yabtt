defprotocol YaBTT.Proto.Parser do
  @moduledoc """
  Protocol and implementations to parse the unparsed map to a parsed map.
  """

  @type unparsed :: %{String.t() => String.t()}
  @type parsed :: %{atom() => String.t()}
  @type error :: {:error, String.t()}
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
      ...>   "port" => "6881",
      ...>   "event" => "started",
      ...>   "mischief-maker" => "I shouldn't be here"
      ...> })
      {:ok,
        %{info_hash: "info_hash",
          peer_id: "peer_id",
          left: 0,
          downloaded: 100,
          uploaded: 0,
          port: 6881,
          event: :started
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
  @need_integerized ["left", "downloaded", "uploaded", "port"]
  # The keys that must be contained in the unparsed map.
  @enforce_keys ["info_hash", "peer_id" | @need_integerized]
  # All the keys that the unparsed map can allow.
  @exhaustive ["ip", "event" | @enforce_keys]
  # The events that must be contained in the unparsed map.
  @events ["started", "stopped", "completed"]

  @doc """
  Parse the unparsed map to a parsed map.

  ## Parameters

  - value: The unparsed map to be parsed.

  """
  @spec parse(Parser.unparsed()) :: Parser.t()
  def parse(value) do
    if contains_enforce_keys(Map.keys(value)) do
      {:ok, for({k, v} <- value, into: %{}, do: do_parse(k, v))}
    else
      {:error, "invalid requeste"}
    end
  end

  @type parsed_value :: String.t() | integer() | atom()

  @compile {:inline, do_parse: 2}
  @spec do_parse(String.t(), String.t()) :: {atom(), parsed_value()}
  defp do_parse(k, v) when k in @exhaustive, do: {String.to_atom(k), handle_value(k, v)}
  defp do_parse(k, v), do: {k, v}

  @compile {:inline, handle_value: 2}
  @spec handle_value(String.t(), String.t()) :: parsed_value()
  defp handle_value(k, v) when k in @need_integerized, do: String.to_integer(v)
  defp handle_value(k, v) when k === "event" and v in @events, do: String.to_atom(v)
  defp handle_value(k, _) when k === "event", do: nil
  defp handle_value(_, v), do: v

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
