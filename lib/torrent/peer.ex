defmodule Torrent.Peer do
  @moduledoc """
  Represents a peer in the BitTorrent.

  A peer is a client that is connected to the tracker. The tracker sends a list
  of peers to the client, and the client connects to them to download the file.

  ## Example
      iex> peer = %Torrent.Peer{
      ...>   peer_id: "aaaaaaaaaaaaaaaaaaaa",
      ...>   ip: "192.168.0.1",
      ...>   port: 6881,
      ...>   uploaded: 0,
      ...>   downloaded: 100,
      ...>   left: 0
      ...> }
      %Torrent.Peer{
        peer_id: "aaaaaaaaaaaaaaaaaaaa",
        ip: "192.168.0.1",
        port: 6881,
        uploaded: 0,
        downloaded: 100,
        left: 0
      }
  """

  defstruct [:peer_id, :ip, :port, :uploaded, :downloaded, :left]

  @enforce_keys [:peer_id, :ip, :port, :uploaded, :downloaded, :left]

  @type t :: %__MODULE__{
          peer_id: String.t(),
          ip: String.t(),
          port: non_neg_integer(),
          uploaded: non_neg_integer(),
          downloaded: non_neg_integer(),
          left: non_neg_integer()
        }
end
