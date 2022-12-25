defmodule YaBTT.Schema.TorrentPeer do
  @moduledoc """
  The schema for a connection between a torrent and a peer.

  A torrent can have many peers, and a peer can be connected to many torrents.
  This schema is used to store the primary keys as a foreign key from the
  torrents and peers tables.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias YaBTT.Schema.{Torrent, Peer}

  @primary_key {:id, :id, autogenerate: true}
  schema "torrents_peers" do
    belongs_to(:torrent, Torrent)
    belongs_to(:peer, Peer)
  end

  @type t :: %__MODULE__{}
  @type changeset_t :: Ecto.Changeset.t(t())
  @type params :: map()

  @doc """
  A changeset to validates the presence of the `torrent_id` and `peer_id`.

  This is used when creating or updating a torrent_peer.

  ## Parameters

    * `torrent_peer` - The torrent_peer to validate.
    * `params` - The parameters to validate.

  ## Examples

      iex> alias YaBTT.Schema.TorrentPeer
      iex> TorrentPeer.changeset(%TorrentPeer{}, %{})
      #Ecto.Changeset<action: nil, changes: %{}, errors: [torrent_id: {"can't be blank", [validation: :required]}, peer_id: {"can't be blank", [validation: :required]}], data: #YaBTT.Schema.TorrentPeer<>, valid?: false>

      iex> alias YaBTT.Schema.TorrentPeer
      iex> TorrentPeer.changeset(%TorrentPeer{}, %{torrent_id: 1, peer_id: 2})
      #Ecto.Changeset<action: nil, changes: %{peer_id: 2, torrent_id: 1}, errors: [], data: #YaBTT.Schema.TorrentPeer<>, valid?: true>
  """
  @spec changeset(changeset_t() | t(), params()) :: changeset_t()
  def changeset(torrent_peer, params) do
    torrent_peer
    |> cast(params, [:torrent_id, :peer_id])
    |> validate_required([:torrent_id, :peer_id])
  end
end
