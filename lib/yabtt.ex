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
  A query function optimized specifically for `insert_or_update/1`.

  Its essence is still `query_peers/2`, but we extract the `t:YaBTT.Query.Peers.id/0`
  and `t:YaBTT.Query.Peers.opts/0` from the `transaction` result. At the same time,
  we wrap the result in a `{:ok, _}` tuple, and propagating the error from
  the `transaction` result.

  ## Parameters

  - `transaction`: the result of transactions

  ## Examples

      iex> torrent = %YaBTT.Schema.Torrent{id: 1}
      iex> opts = %{compact: 1, no_peer_id: 1}
      iex> YaBTT.query_peers({:ok, %{torrent: torrent, params: opts}})

      iex> torrent = %YaBTT.Schema.Torrent{id: 10000}
      iex> opts = %{compact: 0, no_peer_id: 1}
      iex> YaBTT.query_peers({:ok, %{torrent: torrent, params: opts}})

      iex> YaBTT.query_peers({:error, :multi_name, %{}, %{}})

      iex> YaBTT.query_peers({:error, %{}})
  """
  @spec query_peers(t()) :: t()
  def query_peers({:ok, %{torrent: t, params: opts}}), do: {:ok, query_peers(t.id, opts)}
  def query_peers({:error, _, _, _} = error), do: error
  def query_peers({:error, _} = error), do: error

  @type opts :: %{compact: 0 | 1, no_peer_id: 0 | 1}

  @doc """
  Re-export the `YaBTT.Query.Peers.query/2` function.

  But the difference is that the `t:opts/0` parameter is a map with two keys:
  `:compact` and `:no_peer_id`, we use `0` to represent `false` and non-zero
  to represent `true`. The `t:opts/0` map will be converted to a list of
  options (`t:YaBTT.Query.Peers.opts/0`) that will be passed to
  the `YaBTT.Query.Peers.query/2`.

  Learn [how to limit the number of queries by environment variables](`YaBTT.Query.Peers`).

  ## Parameters

  - `id`: the `torrent` id
  - `opts`: the options

  ## Examples

      iex> YaBTT.query_peers(1, %{compact: 0, no_peer_id: 0})

      iex> YaBTT.query_peers(1, %{compact: 0, no_peer_id: 1})

      iex> YaBTT.query_peers(1, %{compact: 1, no_peer_id: 1})
  """
  @spec query_peers(YaBTT.Query.id(), opts()) :: map()
  def query_peers(id, opts) do
    case opts do
      %{compact: c} when c != 0 -> YaBTT.Query.Peers.query(id, mode: :compact)
      %{no_peer_id: np} when np != 0 -> YaBTT.Query.Peers.query(id, mode: :no_peer_id)
      %{compact: 0, no_peer_id: 0} -> YaBTT.Query.Peers.query(id, [])
    end
    |> (&%{
          "interval" => Application.get_env(:yabtt, :interval, 1800),
          "peers" => &1
        }).()
  end

  alias YaBTT.Query.State

  @doc """
  Re-export the `YaBTT.Query.State.query/1` function.

  ## Examples

      iex> YaBTT.query_state(["info_hash_1", "info_hash_2"])
  """
  @spec query_state([State.info_hash()]) :: [State.t() | nil]
  def query_state(info_hashs) when is_list(info_hashs), do: State.query(info_hashs)
end
