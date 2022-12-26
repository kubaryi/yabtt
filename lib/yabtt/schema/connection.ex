defmodule YaBTT.Schema.Connection do
  @moduledoc false

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
    field(:event, :binary)
  end

  @type t :: %__MODULE__{}
  @type changeset_t :: Ecto.Changeset.t(t())
  @type connect :: {term(), term()}
  @type params :: map()

  @doc false
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
