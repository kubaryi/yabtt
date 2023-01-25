defmodule YaBTT.Repo.Migrations.SetInfoHashAsPrimaryKeyForTorrents do
  use Ecto.Migration

  def up do
    drop(unique_index(:connections, [:torrent_id, :peer_id]))

    alter table(:connections) do
      remove(:torrent_id)
    end

    drop(table(:torrents))

    create table(:torrents, primary_key: false) do
      add(:info_hash, :binary_id, null: false, primary_key: true)

      timestamps()
    end

    alter table(:connections) do
      add(:torrent_info_hash, references(:torrents, type: :binary_id, column: :info_hash))
    end

    create(unique_index(:connections, [:torrent_info_hash, :peer_id]))
  end

  def down do
    drop(unique_index(:connections, [:torrent_info_hash, :peer_id]))

    alter table(:connections) do
      remove(:torrent_info_hash)
    end

    drop(table(:torrents, primary_key: false))

    create table(:torrents) do
      add(:info_hash, :binary, null: false)

      timestamps()
    end

    alter table(:connections) do
      add(:torrent_id, references(:torrents))
    end

    create(unique_index(:connections, [:torrent_id, :peer_id]))
  end
end
