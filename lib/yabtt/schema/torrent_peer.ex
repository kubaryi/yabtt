defmodule YaBTT.Schema.TorrentPeer do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias YaBTT.Schema.{Torrent, Peer}
  alias YaBTT.Repo

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

  @doc false
  @spec insert_or_update_changeset(params()) :: changeset_t()
  def insert_or_update_changeset(%{torrent_id: torrent_id, peer_id: peer_id} = params) do
    case Repo.get_by(__MODULE__, torrent_id: torrent_id, peer_id: peer_id) do
      nil -> %__MODULE__{}
      torrent_peer -> torrent_peer
    end
    |> changeset(params)
  end
end
