defmodule YaBTT do
  @moduledoc """
  # YaBTT

  Yet another BitTorrent tracker. It is a BitTorrent Tracker written in Elixir.
  """

  alias YaBTT.Schema.{Peer, Torrent, TorrentPeer, Params}

  @type multi :: Ecto.Multi.t()
  @type info_hash :: binary()
  @type peer_id :: binary()
  @type ip_addr :: :inet.ip_address()
  @type params :: map()

  @doc false
  @spec insert_or_update(Plug.Conn.t()) :: Ecto.Multi.t()
  def insert_or_update(conn) do
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

  @spec insert_or_update_torrent(multi(), params()) :: multi()
  defp insert_or_update_torrent(multi, params) do
    Ecto.Multi.insert_or_update(multi, :torrent, fn %{torrent_repo: repo} ->
      repo |> Torrent.changeset(params)
    end)
  end

  @spec get_torrents(multi(), info_hash()) :: multi()
  defp get_torrents(multi, info_hash) do
    Ecto.Multi.run(multi, :torrent_repo, fn _repo, _changes ->
      {:ok, YaBTT.Repo.get_by(Torrent, info_hash: info_hash) || %Torrent{}}
    end)
  end

  @spec insert_or_update_peer(multi(), params(), ip_addr()) :: multi()
  defp insert_or_update_peer(multi, params, ip) do
    Ecto.Multi.insert_or_update(multi, :peer, fn %{peer_repo: repo} ->
      repo |> Peer.changeset(params, ip)
    end)
  end

  @spec get_peers(multi(), peer_id()) :: multi()
  defp get_peers(multi, peer_id) do
    Ecto.Multi.run(multi, :peer_repo, fn _repo, _changes ->
      {:ok, YaBTT.Repo.get_by(Peer, peer_id: peer_id) || %Peer{}}
    end)
  end

  @spec link_torrents_and_peers(multi()) :: multi()
  defp link_torrents_and_peers(multi) do
    Ecto.Multi.insert_or_update(multi, :torrent_peer, fn %{torrent: t, peer: p} = changes ->
      changes.torrent_peer_repo |> TorrentPeer.changeset(%{torrent_id: t.id, peer_id: p.id})
    end)
  end

  @spec get_torrents_peers(multi()) :: multi()
  defp get_torrents_peers(multi) do
    Ecto.Multi.run(multi, :torrent_peer_repo, fn _repo, %{torrent: t, peer: p} ->
      {:ok, YaBTT.Repo.get_by(TorrentPeer, torrent_id: t.id, peer_id: p.id) || %TorrentPeer{}}
    end)
  end
end
