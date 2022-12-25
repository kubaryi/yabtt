defmodule YaBTT.Schema.TorrentPeer do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias YaBTT.Schema.{Torrent, Peer}

  schema "torrents_peers" do
    belongs_to(:torrent, Torrent)
    belongs_to(:peer, Peer)
  end

  @type t :: %__MODULE__{}
  @type changeset_t :: Ecto.Changeset.t(t())
  @type params :: map()

  @doc false
  @spec changeset(changeset_t() | t(), params()) :: changeset_t()
  def changeset(torrent_peer, params) do
    torrent_peer
    |> cast(params, [:torrent_id, :peer_id])
    |> validate_required([:torrent_id, :peer_id])
  end
end
