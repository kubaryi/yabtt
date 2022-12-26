defmodule YaBTT.Repo.Migrations.CreateTorrentsPeers do
  use Ecto.Migration

  def change do
    create table(:torrents_peers) do
      add(:torrent_id, references(:torrents))
      add(:peer_id, references(:peers))
    end

    create(unique_index(:torrents_peers, [:torrent_id, :peer_id]))
  end
end
