defmodule YaBTT do
  @moduledoc """
  # YaBTT

  Yet another BitTorrent tracker. It is a BitTorrent Tracker written in Elixir.
  """

  alias YaBTT.Proto.{Parser, State, Peer, Resp}

  @type ip_addr :: :inet.ip_address()

  @doc """
  Parse the map.

  ## Parameters

  - value: The map to be parsed.

  ## Example

      iex> YaBTT.parse_params(%{
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

      iex> YaBTT.parse_params(%{})
      :error
  """
  @spec parse_params(Parser.unparsed()) :: {:ok, Parser.parsed()} | :error
  def parse_params(value), do: Parser.parse(value)

  @doc """
  Parse the map.

  ## Parameters

  - value: The map to be parsed.

  ## Example

      iex> YaBTT.parse_params!(%{
      ...>   "info_hash" => "info_hash",
      ...>   "peer_id" => "peer_id",
      ...>   "left" => "0",
      ...>   "downloaded" => "100",
      ...>   "uploaded" => "0",
      ...>   "port" => "6881"
      ...> })
      %{info_hash: "info_hash",
        peer_id: "peer_id",
        left: 0,
        downloaded: 100,
        uploaded: 0,
        port: 6881
      }

      iex> YaBTT.parse_params!(%{})
      ** (RuntimeError) invalid Map
  """
  @spec parse_params!(Parser.unparsed()) :: Parser.parsed()
  def parse_params!(value) do
    case Parser.parse(value) do
      {:ok, parsed} -> parsed
      :error -> raise "invalid Map"
    end
  end

  @doc """
  Convert the parsed map to a `YaBTT.Proto.Peered` struct.

  ## Parameters

  - parsed: The parsed map.
  - ip: The IP address of the peer.

  ## Example

  If it is a string, it will automatically convert ':ip' in the parsed map to `:inet.ip_address()`.

      iex> %{info_hash: "info_hash", peer_id: "peer_id", ip: "1.2.3.4", port: 6881}
      ...> |> YaBTT.convert_peer({1, 2, 3, 5})
      {"info_hash", %YaBTT.Proto.Peered{peer_id: "peer_id", ip: {1, 2, 3, 4}, port: 6881}}

  Otherwise, if the `:ip` in the parsed map is a `nil`, it will use the `ip` passed by parameters.

      iex> %{info_hash: "info_hash", peer_id: "peer_id", port: 6881}
      ...> |> YaBTT.convert_peer({1, 2, 3, 5})
      {"info_hash", %YaBTT.Proto.Peered{peer_id: "peer_id", ip: {1, 2, 3, 5}, port: 6881}}
  """
  @spec convert_peer(Parser.parsed(), ip_addr()) :: Peer.t()
  def convert_peer(parsed, ip), do: Peer.convert(parsed, ip)

  @doc """
  Convert the parsed map to a `YaBTT.Proto.State.t()`.

  ## Parameters

  - parsed: The parsed map.

  ## Example

      iex> %{peer_id: "peer_id", downloaded: 100, uploaded: 20, left: 0, event: "started"}
      ...> |> YaBTT.convert_state()
      {"peer_id", {100, 20, 0}, "started"}

      iex> %{peer_id: "peer_id", downloaded: 100, uploaded: 20, left: 0}
      ...> |> YaBTT.convert_state()
      {"peer_id", {100, 20, 0}, nil}
  """
  @spec convert_state(Parser.parsed()) :: State.t()
  def convert_state(parsed), do: State.convert(parsed)

  @doc """
  Update the peer list and get the response.

  ## Parameters

  - db: The storage endpoint (module).
  - info_hash: The info_hash of the torrent.
  - peer: The peer to be updated.

  ## Example

      iex> db = YaBTT.Database.Cache
      iex> info_hash = "info_hash"
      iex> peer = %YaBTT.Proto.Peered{peer_id: "peer_id", ip: {1, 2, 3, 4}, port: 6881}
      iex> YaBTT.update_and_get(db, info_hash, peer)
      %YaBTT.Proto.Response{
        interval: 3600,
        peers: [
          %YaBTT.Proto.Peered{
            peer_id: "peer_id",
            ip: {1, 2, 3, 4},
            port: 6881
          }
        ]
      }
  """
  @spec update_and_get(atom(), Peer.info_hash(), Peer.peer()) :: Resp.t()
  def update_and_get(db, info_hash, peer) do
    db.update_and_get(info_hash, peer) |> Resp.new()
  end
end
