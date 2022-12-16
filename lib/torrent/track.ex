defmodule Torrent.Track do
  @moduledoc """
  Represents a tracker request.

  The tracker request is sent to the tracker by the client to inform it of the
  client's current status. The tracker responds with a list of peers that the
  client can connect to.

  ## Example
      iex> track = %Torrent.Track{
      ...>   info_hash: "aaaaaaaaaaaaaaaaaaaa",
      ...>   peer: %Torrent.Peer{
      ...>     peer_id: "aaaaaaaaaaaaaaaaaaaa",
      ...>     ip: "192.168.0.1",
      ...>     port: 6881,
      ...>     uploaded: 0,
      ...>     downloaded: 100,
      ...>     left: 0
      ...>   },
      ...> event: "started"
      ...> }
      %Torrent.Track{
        info_hash: "aaaaaaaaaaaaaaaaaaaa",
        peer: %Torrent.Peer{
          peer_id: "aaaaaaaaaaaaaaaaaaaa",
          ip: "192.168.0.1",
          port: 6881,
          uploaded: 0,
          downloaded: 100,
          left: 0
        },
        event: "started"
      }
  """

  defstruct [:info_hash, :peer, :event]

  @enforce_keys [:info_hash, :peer]

  @type t :: %__MODULE__{
          info_hash: String.t(),
          peer: Torrent.Peer.t(),
          event: String.t() | nil
        }
end
