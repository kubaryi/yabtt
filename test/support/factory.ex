defmodule YaBTT.Factory do
  @moduledoc false

  alias YaBTT.Repo
  alias YaBTT.Schema.{Peer, Torrent, Connection}

  @type factory_name :: :peer | :torrent | :connection
  @type t :: Peer.t() | Torrent.t() | Connection.t()

  # Factories

  @spec build(factory_name()) :: t()
  defp build(:peer) do
    %Peer{
      peer_id: "00000000000000000000",
      ip: {127, 0, 0, 1},
      port: 6881,
      inserted_at: ~N[2023-01-01 00:00:00],
      updated_at: ~N[2023-01-01 00:00:00]
    }
  end

  defp build(:torrent) do
    %Torrent{
      info_hash:
        "\x4e\x66\x22\x76\xba\xca\x0f\xdb\x6b\xd6\x0b\x76\x17\x8c\xd1\x19\xd1\x05\x00\x13",
      inserted_at: ~N[2023-01-01 00:00:00],
      updated_at: ~N[2023-01-01 00:00:00]
    }
  end

  defp build(:connection) do
    %Connection{
      peer_id: 1,
      torrent_id: 1,
      uploaded: 1000,
      downloaded: 1000,
      left: 1000,
      event: :started
    }
  end

  # Convenience API

  @spec build(factory_name(), keyword()) :: struct
  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  @spec insert!(factory_name(), keyword) :: t()
  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end

  @spec baseline :: any
  def baseline do
    Ecto.Multi.new()
    |> Ecto.Multi.insert_or_update(:peers, Ecto.Changeset.change(build(:peer)))
    |> Ecto.Multi.insert_or_update(:torrents, Ecto.Changeset.change(build(:torrent)))
    |> Ecto.Multi.insert_or_update(:connections, fn %{peers: p, torrents: t} ->
      Ecto.Changeset.change(build(:connection, peer_id: p.id, torrent_id: t.id))
    end)
    |> Repo.transaction()
  end
end
