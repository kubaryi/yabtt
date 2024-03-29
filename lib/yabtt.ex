defmodule YaBTT do
  @moduledoc """
  # Yet another BitTorrent Tracker

  This is the main entry point for the `YaBTT` as a **library**.

  All the functions will be contained in this module.

  Specifically, the `insert_or_update/1` function is used to insert or update a
  torrent and a peer, and thier status and relationship. The `query/1` function
  is used to query the peers who hold the target torrent.
  """

  alias YaBTT.Schema.{Peer, Torrent, Connection}
  import YaBTT.Repo, only: [get_by: 2, transaction: 1, get: 2]

  @type errors ::
          {:error, Ecto.Multi.name(), Ecto.Changeset.t(), Ecto.Multi.t()}
          | {:error, Bento.Encoder.bencodable()}
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
      ...>   "info_hash" => "f0a15e27fafbffc1c2f18f69fcac2dfa461ff4e7",
      ...>   "peer_id" => "-TR14276775888084597",
      ...>   "key" => "ecsc1ggh0h",
      ...>   "port" => "6881",
      ...>   "uploaded" => "121",
      ...>   "downloaded" => "41421",
      ...>   "left" => "0",
      ...>   "event" => "started"
      ...> }
      iex> conn = %Plug.Conn{params: params, remote_ip: {127, 0, 0, 1}}
      iex> YaBTT.insert_or_update(conn)
  """
  @spec insert_or_update(Plug.Conn.t()) :: t()
  def insert_or_update(conn) do
    Ecto.Multi.new()
    # Disinfect HTTP parameters, then extract `info_hash` and `peer_id`.
    |> Ecto.Multi.run(:deco, fn _, _ -> YaBTT.Deconstruct.deco(conn.params) end)
    # Get the `torrent` from database, or create a new one if it doesn't exist.
    |> Ecto.Multi.insert_or_update(:torrent, fn %{deco: %{ids: %{info_hash: info_hash}}} ->
      (get(Torrent, info_hash) || %Torrent{}) |> Torrent.changeset(conn.params)
    end)
    # Get the `peer` from database, or create a new one if it doesn't exist.
    |> Ecto.Multi.insert_or_update(:peer, fn %{deco: %{ids: %{peer_id: id, key: key}}} ->
      (get_by(Peer, [peer_id: id] ++ if(is_nil(key), do: [], else: [key: key])) || %Peer{})
      |> Peer.changeset(conn.params, conn.remote_ip)
    end)
    # link the `torrent` and the `peer`. If the link already exists, update it.
    |> Ecto.Multi.insert_or_update(:torrent_peer, fn %{torrent: t, peer: p} ->
      (get_by(Connection, torrent_info_hash: t.info_hash, peer_id: p.id) || %Connection{})
      |> Connection.changeset(conn.params, {t.info_hash, p.id})
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

      iex> deco = %YaBTT.Deco{
      ...>   ids: %{info_hash: "f0a15e27fafbffc1c2f18f69fcac2dfa461ff4e7"},
      ...>   config: %{mode: :compact, query_limit: 50}
      ...> }
      iex> YaBTT.query_peers({:ok, %{deco: deco}})

      iex> YaBTT.query_peers({:error, :multi_name, %{}, %{}})

      iex> YaBTT.query_peers({:error, %{}})

      iex> YaBTT.query_peers(:internal_errors)
  """
  @spec query_peers(t()) :: t()
  def query_peers({:ok, %{deco: deco}}), do: query_peers(deco)
  def query_peers({:error, _, _, _} = multi), do: multi
  def query_peers({:error, _} = changeset), do: changeset

  def query_peers(deco) when is_struct(deco, YaBTT.Deco) do
    {:ok, YaBTT.Query.Peers.query(deco)}
  end

  def query_peers(_), do: {:error, "Internal Errors"}

  alias YaBTT.Query.State

  @doc """
  Re-export the `YaBTT.Query.State.query/1` function.

  ## Examples

      iex> YaBTT.query_state(["info_hash_1", "info_hash_2"])

      iex> YaBTT.query_state({:ok, %{info_hash: ["info_hash_1", "info_hash_2"]}})

      iex> YaBTT.query_state({:error, %{}})
  """
  @spec query_state(t() | [State.info_hash()]) :: t() | State.t()
  def query_state(info_hashs) when is_list(info_hashs), do: State.query(info_hashs)
  def query_state({:ok, %{info_hash: info_hashs}}), do: {:ok, State.query(info_hashs)}
  def query_state({:error, _} = changeset), do: changeset
end
