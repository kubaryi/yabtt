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

  @primary_key false
  @foreign_key_type :binary_id
  schema "torrents" do
    field(:info_hash, :binary_id, primary_key: true)

    many_to_many(:peers, YaBTT.Schema.Peer,
      join_through: YaBTT.Schema.Connection,
      join_keys: [
        torrent_info_hash: :info_hash,
        peer_id: :id
      ]
    )

    timestamps()
  end

  @type t :: %__MODULE__{}
  @type changeset_t :: Ecto.Changeset.t(t())
  @type params :: map()

  @doc """
  A torrent can be created or updated with a changeset. The changeset requires
  the info_hash to be present.

  ## Parameters

    * `torrent` - The torrent to validate.
    * `params` - The parameters to validate.

  ## Examples

      iex> alias YaBTT.Schema.Torrent
      iex> Torrent.changeset(%Torrent{}, %{
      ...>   "info_hash" => <<18, 52, 86, 120, 154, 188, 222, 241, 35, 69, 103, 137, 171, 205, 239, 18, 52, 86, 120, 154>>})
      #Ecto.Changeset<action: nil, changes: %{info_hash: <<18, 52, 86, 120, 154, 188, 222, 241, 35, 69, 103, 137, 171, 205, 239, 18, 52, 86, 120, 154>>}, errors: [], data: #YaBTT.Schema.Torrent<>, valid?: true>
  """
  @spec changeset(changeset_t() | t(), params()) :: changeset_t()
  def changeset(torrent, params) do
    torrent
    |> cast(params, [:info_hash])
    |> validate_required([:info_hash])
  end
end
