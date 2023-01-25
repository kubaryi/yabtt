defmodule YaBTT.Repo.Migrations.AddKeyForPeers do
  use Ecto.Migration

  def change do
    alter table(:peers) do
      add(:key, :binary, null: true)
    end
  end
end
