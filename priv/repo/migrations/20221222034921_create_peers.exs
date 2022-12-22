defmodule YaBTT.Repo.Migrations.CreatePeers do
  use Ecto.Migration

  def change do
    create table(:peers) do
      add :peer_id, :binary, null: false
      add :ip, :binary, null: false
      add :port, :integer, null: false
    end
  end
end
