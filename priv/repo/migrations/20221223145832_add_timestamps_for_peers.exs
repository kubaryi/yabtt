defmodule YaBTT.Repo.Migrations.AddTimestampsForPeers do
  use Ecto.Migration

  def change do
    alter table(:peers) do
      timestamps()
    end
  end
end
