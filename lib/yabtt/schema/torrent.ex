defmodule YaBTT.Schema.Torrent do
  @moduledoc """
  The schema for torrents.

  ## Fields

    * `info_hash` - The info hash of the torrent.
    * `peers` - The peers that are currently seeding or leeching the torrent.

  ## Associations

    * `peers` - The peers that are currently seeding or leeching the torrent.

  ## Indexes

  * `info_hash` - The info hash of the torrent.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias YaBTT.Schema.{TorrentPeer, Peer}
  alias YaBTT.Repo

  @primary_key {:id, :id, autogenerate: true}
  schema "torrents" do
    field(:info_hash, :binary)
    many_to_many(:peers, Peer, join_through: TorrentPeer)

    timestamps()
  end

  @type t :: %__MODULE__{}
  @type changeset_t :: Ecto.Changeset.t(t())
  @type params :: map()

  @doc """
  A torrent can be created or updated with a changeset. The changeset requires
  the info_hash to be present.
  """
  @spec changeset(changeset_t() | t(), params()) :: changeset_t()
  def changeset(torrent, params) do
    torrent
    |> cast(params, [:info_hash])
    |> validate_required([:info_hash])
  end

  @doc false
  @spec insert_or_update_changeset(params()) :: changeset_t()
  def insert_or_update_changeset(params) do
    changeset = changeset(%__MODULE__{}, params)

    with {:ok, info_hash} <- fetch_change(changeset, :info_hash),
         %{id: _} = data <- Repo.get_by(__MODULE__, info_hash: info_hash) do
      data |> changeset(params)
    else
      _ -> changeset
    end
  end
end
