defmodule YaBTT.Repo.Migrations.AddTimestampsForTorrents do
  use Ecto.Migration

  def change do
    alter table(:torrents) do
      timestamps()
    end
  end
end
