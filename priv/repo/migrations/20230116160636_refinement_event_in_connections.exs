defmodule YaBTT.Repo.Migrations.RefinementEventInConnections do
  use Ecto.Migration

  def change do
    alter table(:connections) do
      add(:started, :boolean, null: false)
      add(:completed, :boolean, default: false)
    end
  end
end
