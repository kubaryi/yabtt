defmodule YaBTT.Repo.Migrations.CreateTorrents do
  use Ecto.Migration

  def change do
    create table(:torrents) do
      add(:info_hash, :binary, null: false)

      timestamps()
    end
  end
end
