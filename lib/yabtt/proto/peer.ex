defmodule YaBTT.Proto.Peered do
  @moduledoc """
  Represents a peer in the BitTorrent.

  A peer is a client that is connected to the tracker. The tracker sends a list
  of peers to the client, and the client connects to them to download the file.

  ## Example
      iex> %YaBTT.Proto.Peered{peer_id: "peer_id", ip: {1, 2, 3, 4}, port: 6881}
  """

  @enforce_keys [:peer_id, :port]
  defstruct [:peer_id, :ip, :port]

  @type ip_addr :: :inet.ip_address()
  @type port_num :: :inet.port_number()
  @type t :: %__MODULE__{peer_id: String.t(), ip: ip_addr(), port: port_num()}
end

defprotocol YaBTT.Proto.Peer do
  @moduledoc """
  Protocol and implementations to convert the peerable to `YaBTT.Proto.Peered.t()`.
  """

  alias YaBTT.Proto.Peered
  alias YaBTT.Proto.Norm

  @type peerable :: Norm.normalized()
  @type peer :: Peered.t()
  @type info_hash :: String.t()
  @type t :: {info_hash(), peer()}

  @doc """
  Convert the peerable to peer struct.

  ## Parameters

  - value: The peerable to be converted.
  - ip: The IP address of the peer.

  ## Example

  It will automatically convert the `ip` to `:inet.ip_address()` if it is a
  string.

      iex> %{info_hash: "info_hash", peer_id: "peer_id", ip: "1.2.3.4", port: 6881}
      ...> |> YaBTT.Proto.Peer.convert({1, 2, 3, 5})
      {"info_hash", %YaBTT.Proto.Peered{peer_id: "peer_id", ip: {1, 2, 3, 4}, port: 6881}}
  """
  @spec convert(peerable(), Peered.ip_addr()) :: t()
  def convert(value, ip)
end

defimpl YaBTT.Proto.Peer, for: Map do
  @moduledoc """
  Implementation of `YaBTT.Proto.Peer` for `Map`.
  """

  alias YaBTT.Proto.Peered
  alias YaBTT.Proto.Peer

  @doc """
  Convert the normalized map to a peer.

  ## Parameters

  - value: The normalized map to be converted.
  - ip: The IP address of the peer.

  ## Example

      iex> %{info_hash: "info_hash", peer_id: "peer_id", port: 6881}
      ...> |> YaBTT.Proto.Peer.convert({1, 2, 3, 5})
      {"info_hash", %YaBTT.Proto.Peered{peer_id: "peer_id", ip: {1, 2, 3, 5}, port: 6881}}

      iex> YaBTT.Proto.Peer.convert(%{}, {1, 2, 3, 5})
      {nil, %YaBTT.Proto.Peered{peer_id: nil, ip: {1, 2, 3, 5}, port: nil}}
  """
  @spec convert(Peer.peerable(), YaBTT.ip_addr()) :: Peer.t()
  def convert(normalized_map, ip) do
    peer = struct(Peered, normalized_map) |> handle_ip(ip)

    {normalized_map[:info_hash], peer}
  end

  @spec handle_ip(Peered.t(), Peered.ip_addr()) :: Peered.t()
  defp handle_ip(peer, remote_ip) do
    case :inet.parse_address(to_charlist(peer.ip)) do
      {:ok, ip} -> %{peer | ip: ip}
      _ -> %{peer | ip: remote_ip}
    end
  end
end
