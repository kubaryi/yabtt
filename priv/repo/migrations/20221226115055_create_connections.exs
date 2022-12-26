defmodule YaBTT.Repo.Migrations.CreateConnections do
  use Ecto.Migration

  def change do
    create table(:connections) do
      add(:torrent_id, references(:torrents))
      add(:peer_id, references(:peers))
      add(:downloaded, :integer)
      add(:uploaded, :integer)
      add(:left, :integer)
      add(:event, :binary)
    end

    create(unique_index(:connections, [:torrent_id, :peer_id]))
  end
end
