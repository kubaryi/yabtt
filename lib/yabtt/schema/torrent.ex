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

  defimpl Bento.Encoder do
    @moduledoc false

    use Bento.Encode

    alias YaBTT.Schema.Torrent
    alias Bento.Encoder

    @doc false
    @spec encode(Torrent.t()) :: Encoder.t()
    def encode(%{id: _} = torrent) do
      torrent
      |> Map.take([:peers])
      |> Map.put(:interval, 3600)
      |> Encoder.encode()
    end
  end
end
