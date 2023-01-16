defmodule YaBTT.Repo.Migrations.RenameTorrentsPeersToConnections do
  use Ecto.Migration

  def change do
    drop(unique_index(:torrents_peers, [:torrent_id, :peer_id]))

    rename(table(:torrents_peers), to: table(:connections))

    alter table(:connections) do
      add(:downloaded, :integer)
      add(:uploaded, :integer)
      add(:left, :integer)
      add(:event, :integer)
    end

    create(unique_index(:connections, [:torrent_id, :peer_id]))
  end
end
