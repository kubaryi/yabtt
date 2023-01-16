defmodule YaBTT.Repo.Migrations.RenameInfoHashToTorrentIdInTorrentsPeers do
  use Ecto.Migration

  def change do
    drop(unique_index(:torrents_peers, [:info_hash, :peer_id]))

    rename(table(:torrents_peers), :info_hash, to: :torrent_id)

    create(unique_index(:torrents_peers, [:torrent_id, :peer_id]))
  end
end
