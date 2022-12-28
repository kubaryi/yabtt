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

  alias YaBTT.Schema.{Connection, Peer}

  @primary_key {:id, :id, autogenerate: true}
  schema "torrents" do
    field(:info_hash, :binary)
    many_to_many(:peers, Peer, join_through: Connection)

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
      iex> Torrent.changeset(%Torrent{}, %{info_hash: "info_hash"})
      #Ecto.Changeset<action: nil, changes: %{info_hash: "info_hash"}, errors: [], data: #YaBTT.Schema.Torrent<>, valid?: true>

      iex> alias YaBTT.Schema.Torrent
      iex> Torrent.changeset(%Torrent{}, %{})
      #Ecto.Changeset<action: nil, changes: %{}, errors: [info_hash: {"can't be blank", [validation: :required]}], data: #YaBTT.Schema.Torrent<>, valid?: false>
  """
  @spec changeset(changeset_t() | t(), params()) :: changeset_t()
  def changeset(torrent, params) do
    torrent
    |> cast(params, [:info_hash])
    |> validate_required([:info_hash])
  end

  defimpl YaBTT.Response do
    @moduledoc """
    Implements the `YaBTT.Response` protocol for `YaBTT.Schema.Torrent`.
    """

    alias YaBTT.{Schema.Torrent, Response}

    @doc """
    Extracts a `YaBTT.Schema.Torrent` into a `map()`.
    """
    @spec extract(Torrent.t()) :: map()
    def extract(torrent) do
      %{
        interval: Application.get_env(:yabtt, :interval, 3600),
        peers: Stream.map(torrent.peers, &Response.extract/1)
      }
    end
  end
end
