defmodule YaBTT do
  @moduledoc """
  # YaBTT

  Yet another BitTorrent tracker. It is a BitTorrent Tracker written in Elixir.
  """

  alias YaBTT.Schema.{Peer, Torrent, Params, Connection}

  @type info_hash :: binary()
  @type peer_id :: binary()
  @type params :: map()

  @typep changeset_t :: Ecto.Changeset.t()
  @typep multi_name :: Ecto.Multi.name()

  @doc """
  A transaction that inserts or updates a torrent and a peer.

  ## Examples

      iex> params = %{
      ...>   "info_hash" => "f0a15e27fafbffc1c2f18f69fcac2dfa461ff4e8",
      ...>   "peer_id" => "-TR14276775888084598",
      ...>   "port" => "6881",
      ...>   "uploaded" => "121",
      ...>   "downloaded" => "41421",
      ...>   "left" => "0",
      ...>   "event" => "completed"
      ...> }
      iex> conn = %Plug.Conn{params: params, remote_ip: {127, 0, 0, 1}}
      iex> YaBTT.insert_or_update(conn)
  """
  @spec insert_or_update(Plug.Conn.t()) ::
          {:ok, map()}
          | {:error, changeset_t()}
          | {:error, multi_name(), changeset_t(), Ecto.Multi.t()}
  def(insert_or_update(conn)) do
    import YaBTT.Repo, only: [get_by: 2, transaction: 1]

    with {:ok, %{info_hash: info_hash, peer_id: peer_id}} <- Params.apply(conn.params) do
      Ecto.Multi.new()
      # Get the `torrent` from database, or create a new one if it doesn't exist.
      |> Ecto.Multi.insert_or_update(:torrent, fn _ ->
        (get_by(Torrent, info_hash: info_hash) || %Torrent{}) |> Torrent.changeset(conn.params)
      end)
      # Get the `peer` from database, or create a new one if it doesn't exist.
      |> Ecto.Multi.insert_or_update(:peer, fn _ ->
        (get_by(Peer, peer_id: peer_id) || %Peer{}) |> Peer.changeset(conn.params, conn.remote_ip)
      end)
      # link the `torrent` and the `peer`. If the link already exists, update it.
      |> Ecto.Multi.insert_or_update(:torrent_peer, fn %{torrent: t, peer: p} ->
        (get_by(Connection, torrent_id: t.id, peer_id: p.id) || %Connection{})
        |> Connection.changeset(conn.params, {t.id, p.id})
      end)
      |> transaction()
    end
  end

  @doc """
  Query the torrent and its peers.

  ## Examples

      iex> torrent = %YaBTT.Schema.Torrent{id: 1}
      iex> YaBTT.query(torrent)

      iex> torrent = %YaBTT.Schema.Torrent{id: 10000}
      iex> YaBTT.query(torrent)
  """
  @spec query(Torrent.t()) :: {:ok, Torrent.t()} | :error
  def query(torrent) when is_struct(torrent, Torrent) do
    case YaBTT.Repo.preload(torrent, :peers) do
      nil -> :error
      torrent -> {:ok, torrent}
    end
  end
end
