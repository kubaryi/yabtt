defmodule YaBTT.Schema.Connection do
  @moduledoc """
  The schema for the `connections` table.

  A torrent can have many peers, and a peer can be connected to many torrents.
  This schema is used to store the primary keys as a foreign key from the
  torrents and peers tables.

  At the same time, this table is also responsible for maintaining the status
  of the link. Including `uploaded', `downloaded', `left` and `event`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias YaBTT.Schema.{Torrent, Peer}

  @primary_key {:id, :id, autogenerate: true}
  schema "connections" do
    belongs_to(:torrent, Torrent)
    belongs_to(:peer, Peer)
    field(:uploaded, :integer)
    field(:downloaded, :integer)
    field(:left, :integer)
    field(:event, YaBTT.Types.Event)
  end

  @type t :: %__MODULE__{}
  @type changeset_t :: Ecto.Changeset.t(t())
  @type connect :: {term(), term()}
  @type params :: map()

  @doc """
  A changeset to validate if the status of the connection is valid. This
  `torrent_id` and `peer_id` are used to connect with the `torrents` and
  `peers` tables.

  ## Parameters

  - `connection`: the changeset or `YaBTT.Schema.Connection`
  - `params`: the request parameters
  - `connect`: the `torrent_id` and `peer_id` to connect with the `torrents` and `peers` tables

  ## Examples

      iex> alias YaBTT.Schema.Connection
      iex> params = %{
      ...>   "uploaded" => "121",
      ...>   "downloaded" => "41421",
      ...>   "left" => "0",
      ...>   "event" => "started"
      ...> }
      iex> changeset = Connection.changeset(%Connection{}, params, {1, 1})
      iex> changeset.valid?
      true
      iex> changeset.changes
      %{downloaded: 41421, event: :started, left: 0, peer_id: 1, torrent_id: 1, uploaded: 121}

      iex> alias YaBTT.Schema.Connection
      iex> params = %{"uploaded" => "121", "downloaded" => "41421", "left" => "0"}
      iex> changeset = Connection.changeset(%Connection{}, params, {1, 1})
      iex> changeset.valid?
      false
      iex> changeset.errors
      [event: {"can't be blank for new peers", [validation: :event]}]
  """
  @spec changeset(changeset_t() | t(), params(), connect()) :: changeset_t()
  def changeset(connection, params, {torrent_id, peer_id}) do
    connection
    |> cast(params, [:uploaded, :downloaded, :left, :event])
    |> validate_required([:uploaded, :downloaded, :left])
    |> put_change(:torrent_id, torrent_id)
    |> put_change(:peer_id, peer_id)
    |> validate_event()
  end

  @spec validate_event(changeset_t()) :: changeset_t()
  defp validate_event(changeset) do
    with {:data, nil} <- fetch_field(changeset, :event) do
      add_error(changeset, :event, "can't be blank for new peers", validation: :event)
    else
      _ -> changeset
    end
  end
end
