defmodule YaBTT.Repo.Migrations.RemoveEventFromConnections do
  use Ecto.Migration

  def change do
    alter table(:connections) do
      remove(:event, :integer)
    end
  end
end
