defmodule YaBTT.Repo.Migrations.CreateTorrentsPeers do
  use Ecto.Migration

  def change do
    create table(:torrents_peers) do
      add :info_hash, references(:torrents)
      add :peer_id, references(:peers)
    end

    create unique_index(:torrents_peers, [:info_hash, :peer_id])
  end
end
