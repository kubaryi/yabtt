defmodule YaBTT do
  @moduledoc """
  # Yet another BitTorrent Tracker

  This is the main entry point for the `YaBTT` as a **library**.

  All the functions will be contained in this module.

  Specifically, the `insert_or_update/1` function is used to insert or update a
  torrent and a peer, and thier status and relationship. The `query/1` function
  is used to query the peers who hold the target torrent.
  """

  alias YaBTT.Schema.{Peer, Torrent, Params, Connection}

  @type errors ::
          {:error, Ecto.Multi.name(), Ecto.Changeset.t(), Ecto.Multi.t()}
          | {:error, Ecto.Changeset.t()}
  @type t(res) :: {:ok, res} | errors()
  @type t :: t(map())

  @doc """
  A transaction that inserts or updates a torrent and a peer.

  The main process of the transaction:

  1. The transaction begins.
  2. Read and disinfect the HTTP parameters.
  3. Get the `torrent` from database, or create a new one if it doesn't exist.
  4. Get the `peer` from database, or create a new one if it doesn't exist.
  5. Create a `connection` between the `torrent` and the `peer`, and record
     the status of the `connection`.
  6. Commit the transaction.

  ## Parameters

  - `conn`: the `Plug.Conn` struct

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
  @spec insert_or_update(Plug.Conn.t()) :: t()
  def(insert_or_update(conn)) do
    import YaBTT.Repo, only: [get_by: 2, transaction: 1]

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

  > #### Implementer's Note {: .info}
  >
  > Even 30 peers is **plenty**, the official client version 3 in fact only actively
  > forms new connections if it has less than 30 peers and will refuse connections if it has 55.
  > **This value is important to performance.** When a new piece has completed download,
  > HAVE messages (see below) will need to be sent to most active peers.
  > As a result the cost of broadcast traffic grows in direct proportion to the number of peers. Above 25,
  > new peers are highly unlikely to increase download speed. UI designers are strongly
  > advised to make this obscure and hard to change as it is very rare to be useful to do so.
  >
  >  See: [Bittorrent Protocol Specification v1.0][specification]

  As required by the [specification], the queried peers will be **random**.

  ## Parameters

  - `transaction`: the result of transactions

  ## Examples

      iex> torrent = %YaBTT.Schema.Torrent{id: 1}
      iex> opts = %{compact: 0, no_peer_id: 0}
      iex> YaBTT.query({:ok, %{torrent: torrent, params: opts}})

      iex> torrent = %YaBTT.Schema.Torrent{id: 10000}
      iex> opts = %{compact: 1, no_peer_id: 1}
      iex> YaBTT.query({:ok, %{torrent: torrent, params: opts}})

      iex> YaBTT.query({:error, :multi_name, %{}, %{}})

      iex> YaBTT.query({:error, %{}})

  <!-- links -->

  [specification]: https://wiki.theory.org/BitTorrentSpecification#Tracker_Response
  """
  @spec query(t()) :: t()
  def query({:ok, %{torrent: t, params: opts}}), do: {:ok, query(t.id, opts)}
  def query({:error, _, _, _} = error), do: error
  def query({:error, _} = error), do: error

  @type opts :: %{compact: 0 | 1, no_peer_id: 0 | 1}

  @doc false
  @spec query(YaBTT.Query.id(), opts()) :: map()
  def query(id, opts) do
    case opts do
      %{compact: c} when c != 0 -> YaBTT.Query.query_peers(id, mode: :compact)
      %{no_peer_id: np} when np != 0 -> YaBTT.Query.query_peers(id, mode: :no_peer_id)
      %{compact: 0, no_peer_id: 0} -> YaBTT.Query.query_peers(id, [])
    end
    |> (&%{
          "interval" => Application.get_env(:yabtt, :interval, 1800),
          "peers" => &1
        }).()
  end
end
