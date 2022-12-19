defmodule YaBTT do
  @moduledoc """
  # YaBTT

  Yet another BitTorrent tracker. It is a BitTorrent Tracker written in Elixir.
  """

  alias YaBTT.Proto.Norm
  alias YaBTT.Proto.State
  alias YaBTT.Proto.Peer
  alias YaBTT.Proto.Resp

  @type ip_addr :: :inet.ip_address()

  @doc """
  Normalize the map.

  ## Parameters

  - value: The map to be normalized.

  ## Example

      iex> YaBTT.normalize_map(%{
      ...>   "info_hash" => "info_hash",
      ...>   "peer_id" => "peer_id",
      ...>   "left" => "0",
      ...>   "downloaded" => "0",
      ...>   "uploaded" => "0",
      ...>   "port" => "6881"
      ...> })
      {:ok,
        %{info_hash: "info_hash",
          peer_id: "peer_id",
          left: "0",
          downloaded: "0",
          uploaded: "0",
          port: "6881"
        }
      }

      iex> YaBTT.normalize_map(%{})
      :error
  """
  @spec normalize_map(Norm.unnormalized()) :: {:ok, Norm.normalized()} | :error
  def normalize_map(value), do: Norm.normalize(value)

  @doc """
  Normalize the map.

  ## Parameters

  - value: The map to be normalized.

  ## Example

      iex> YaBTT.normalize_map!(%{
      ...>   "info_hash" => "info_hash",
      ...>   "peer_id" => "peer_id",
      ...>   "left" => "0",
      ...>   "downloaded" => "0",
      ...>   "uploaded" => "0",
      ...>   "port" => "6881"
      ...> })
      %{info_hash: "info_hash",
        peer_id: "peer_id",
        left: "0",
        downloaded: "0",
        uploaded: "0",
        port: "6881"
      }

      iex> YaBTT.normalize_map!(%{})
      ** (RuntimeError) invalid Map
  """
  @spec normalize_map!(Norm.unnormalized()) :: Norm.normalized()
  def normalize_map!(value) do
    case Norm.normalize(value) do
      {:ok, normalized} -> normalized
      :error -> raise "invalid Map"
    end
  end

  @doc """
  Convert the normalized map to a `YaBTT.Proto.Peered` struct.

  ## Parameters

  - normalized: The normalized map.
  - ip: The IP address of the peer.

  ## Example

  If it is a string, it will automatically convert ':ip' in the normalized map to `:inet.ip_address()`.

      iex> %{info_hash: "info_hash", peer_id: "peer_id", ip: "1.2.3.4", port: 6881}
      ...> |> YaBTT.convert_peer({1, 2, 3, 5})
      {"info_hash", %YaBTT.Proto.Peered{peer_id: "peer_id", ip: {1, 2, 3, 4}, port: 6881}}

  Otherwise, if the `:ip` in the normalized map is a `nil`, it will use the `ip` passed by parameters.

      iex> %{info_hash: "info_hash", peer_id: "peer_id", port: 6881}
      ...> |> YaBTT.convert_peer({1, 2, 3, 5})
      {"info_hash", %YaBTT.Proto.Peered{peer_id: "peer_id", ip: {1, 2, 3, 5}, port: 6881}}
  """
  @spec convert_peer(Norm.normalized(), ip_addr()) :: Peer.t()
  def convert_peer(normalized, ip), do: Peer.convert(normalized, ip)

  @doc """
  Convert the normalized map to a `YaBTT.Proto.State.t()`.

  ## Parameters

  - normalized: The normalized map.

  ## Example

      iex> %{peer_id: "peer_id", downloaded: 100, uploaded: 20, left: 0, event: "started"}
      ...> |> YaBTT.convert_state()
      {"peer_id", {100, 20, 0}, "started"}

      iex> %{peer_id: "peer_id", downloaded: 100, uploaded: 20, left: 0}
      ...> |> YaBTT.convert_state()
      {"peer_id", {100, 20, 0}, nil}
  """
  @spec convert_state(Norm.normalized()) :: State.t()
  def convert_state(normalized), do: State.convert(normalized)

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
