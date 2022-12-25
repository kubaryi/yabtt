defmodule YaBTT do
  @moduledoc """
  # YaBTT

  Yet another BitTorrent tracker. It is a BitTorrent Tracker written in Elixir.
  """

  alias YaBTT.Schema.{Peer, Torrent, TorrentPeer, Params}

  @doc false
  @spec insert_or_update(Plug.Conn.t()) :: Ecto.Multi.t()
  def insert_or_update(conn) do
    with {:ok, %{info_hash: info_hash, peer_id: peer_id}} <- Params.apply(conn.params) do
      Ecto.Multi.new()
      |> Torrent.insert_or_update_after_get(info_hash, conn.params)
      |> Peer.insert_or_update_after_get(peer_id, conn.params, conn.remote_ip)
      |> Ecto.Multi.insert_or_update(:torrent_peer, fn %{torrent: torrent, peer: peer} = changes ->
        with {:ok, torrent_id} <- Map.fetch(torrent, :id),
             {:ok, peer_id} <- Map.fetch(peer, :id) do
          TorrentPeer.insert_or_update_changeset(%{torrent_id: torrent_id, peer_id: peer_id})
        else
          :error -> changes
        end
      end)
      |> YaBTT.Repo.transaction()
    end
  end
end
