defmodule YaBTT.Repo.Migrations.CreateIndexForPeerIdAndKeyInPeers do
  use Ecto.Migration

  def change do
    create(unique_index(:peers, [:peer_id, :key]))
  end
end
