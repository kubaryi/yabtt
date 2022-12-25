defmodule YaBTT do
  @moduledoc """
  # YaBTT

  Yet another BitTorrent tracker. It is a BitTorrent Tracker written in Elixir.
  """

  alias YaBTT.Schema.{Peer, Torrent, TorrentPeer, Params}

  @type info_hash :: binary()
  @type peer_id :: binary()
  @type params :: map()

  @typep changeset_t :: Ecto.Changeset.t()
  @typep multi_name :: Ecto.Multi.name()

  @doc """
  A transaction that inserts or updates a torrent and a peer.

  ## Examples

      iex> params = %{"info_hash" => "info_hash", "peer_id" => "peer_id", "port" => "6810"}
      iex> conn = %Plug.Conn{params: params, remote_ip: {127, 0, 0, 1}}
      iex> YaBTT.insert_or_update(conn)
  """
  @spec insert_or_update(Plug.Conn.t()) ::
          {:ok, map()}
          | {:error, changeset_t()}
          | {:error, multi_name(), changeset_t(), Ecto.Multi.t()}
  def(insert_or_update(conn)) do
    with {:ok, %{info_hash: info_hash, peer_id: peer_id}} <- Params.apply(conn.params) do
      Ecto.Multi.new()
      |> get_torrents(info_hash)
      |> insert_or_update_torrent(conn.params)
      |> get_peers(peer_id)
      |> insert_or_update_peer(conn.params, conn.remote_ip)
      |> get_torrents_peers()
      |> link_torrents_and_peers()
      |> YaBTT.Repo.transaction()
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

  @spec insert_or_update_torrent(Ecto.Multi.t(), params()) :: Ecto.Multi.t()
  defp insert_or_update_torrent(multi, params) do
    Ecto.Multi.insert_or_update(multi, :torrent, fn %{torrent_repo: repo} ->
      repo |> Torrent.changeset(params)
    end)
  end

  @spec get_torrents(Ecto.Multi.t(), info_hash()) :: Ecto.Multi.t()
  defp get_torrents(multi, info_hash) do
    Ecto.Multi.run(multi, :torrent_repo, fn _repo, _changes ->
      {:ok, YaBTT.Repo.get_by(Torrent, info_hash: info_hash) || %Torrent{}}
    end)
  end

  @spec insert_or_update_peer(Ecto.Multi.t(), params(), ip_addr()) :: Ecto.Multi.t()
  defp insert_or_update_peer(multi, params, ip) do
    Ecto.Multi.insert_or_update(multi, :peer, fn %{peer_repo: repo} ->
      repo |> Peer.changeset(params, ip)
    end)
  end

  @typep ip_addr :: YaBTT.Schema.Peer.ip_addr()

  @spec get_peers(Ecto.Multi.t(), peer_id()) :: Ecto.Multi.t()
  defp get_peers(multi, peer_id) do
    Ecto.Multi.run(multi, :peer_repo, fn _repo, _changes ->
      {:ok, YaBTT.Repo.get_by(Peer, peer_id: peer_id) || %Peer{}}
    end)
  end

  @spec link_torrents_and_peers(Ecto.Multi.t()) :: Ecto.Multi.t()
  defp link_torrents_and_peers(multi) do
    Ecto.Multi.insert_or_update(multi, :torrent_peer, fn %{torrent: t, peer: p} = changes ->
      changes.torrent_peer_repo |> TorrentPeer.changeset(%{torrent_id: t.id, peer_id: p.id})
    end)
  end

  @spec get_torrents_peers(Ecto.Multi.t()) :: Ecto.Multi.t()
  defp get_torrents_peers(multi) do
    Ecto.Multi.run(multi, :torrent_peer_repo, fn _repo, %{torrent: t, peer: p} ->
      {:ok, YaBTT.Repo.get_by(TorrentPeer, torrent_id: t.id, peer_id: p.id) || %TorrentPeer{}}
    end)
  end
end
