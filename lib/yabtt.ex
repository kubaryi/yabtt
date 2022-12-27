defmodule YaBTT do
  @moduledoc """
  # Yet another BitTorrent Tracker

  This is the main entry point for the `YaBTT` as a **library**.

  All the functions will be contained in this module.

  Specifically, the `insert_or_update/1` function is used to insert or update a
  torrent and a peer, and thier status and relationship. The `query/1` function
  is used to query the peers who hold the target torrent.
  """

  import YaBTT.Repo, only: [get_by: 2, transaction: 1]
  import Ecto.Query

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
    Ecto.Multi.new()
    # Disinfect HTTP parameters, then extract `info_hash` and `peer_id`.
    |> Ecto.Multi.run(:params, fn _, _ -> Params.apply(conn.params) end)
    # Get the `torrent` from database, or create a new one if it doesn't exist.
    |> Ecto.Multi.insert_or_update(:torrent, fn %{params: %{info_hash: info_hash}} ->
      (get_by(Torrent, info_hash: info_hash) || %Torrent{}) |> Torrent.changeset(conn.params)
    end)
    # Get the `peer` from database, or create a new one if it doesn't exist.
    |> Ecto.Multi.insert_or_update(:peer, fn %{params: %{peer_id: peer_id}} ->
      (get_by(Peer, peer_id: peer_id) || %Peer{}) |> Peer.changeset(conn.params, conn.remote_ip)
    end)
    # link the `torrent` and the `peer`. If the link already exists, update it.
    |> Ecto.Multi.insert_or_update(:torrent_peer, fn %{torrent: t, peer: p} ->
      (get_by(Connection, torrent_id: t.id, peer_id: p.id) || %Connection{})
      |> Connection.changeset(conn.params, {t.id, p.id})
    end)
    |> transaction()
  end

  @doc """
  Query the torrent and its peers.

  You can use the [environment variable](./readme.html#configuration) `YABTT_QUERY_LIMIT` to
  limit the number of peers returned per query. The value default to 50, but we recommend
  you to set it smaller, like 30. Because this value is important to performance.

  Practice tells us that even 30 peers is plenty.

  > #### Implementer's Note {: .neutral}
  >
  > Even 30 peers is **plenty**, the official client version 3 in fact only actively
  > forms new connections if it has less than 30 peers and will refuse connections if it has 55.
  > **This value is important to performance.** When a new piece has completed download,
  > HAVE messages (see below) will need to be sent to most active peers.
  > As a result the cost of broadcast traffic grows in direct proportion to the number of peers. Above 25,
  > new peers are highly unlikely to increase download speed. UI designers are strongly
  > advised to make this obscure and hard to change as it is very rare to be useful to do so.
  >
  >  See: https://wiki.theory.org/BitTorrentSpecification#Tracker_Response

  ## Examples

      iex> torrent = %YaBTT.Schema.Torrent{id: 1}
      iex> YaBTT.query(torrent)

      iex> torrent = %YaBTT.Schema.Torrent{id: 10000}
      iex> YaBTT.query(torrent)
  """
  @spec query(Torrent.t()) :: {:ok, Torrent.t()} | :error
  def query(torrent) when is_struct(torrent, Torrent) do
    query_limit = Application.get_env(:yabtt, :query_limit, 50)
    query = from(p in Peer, order_by: [desc: p.updated_at], limit: ^query_limit)

    case YaBTT.Repo.preload(torrent, peers: query) do
      nil -> :error
      torrent -> {:ok, torrent}
    end
  end
end
