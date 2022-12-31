defmodule YaBTT.Query.Peers do
  @moduledoc """
  This module is used to query the peers who hold the target torrent.

  You can use the [environment variable](./readme.html#configuration) `YABTT_QUERY_LIMIT` to
  limit the number of peers returned per query. The value default to 50, but we recommend
  you to set it smaller, like 30. Because this value is important to performance.

  Practice tells us that even 30 peers is plenty.

  > #### Implementer's Note {: .info}
  >
  > Even 30 peers is **plenty**, the official client version 3 in fact only actively
  > forms new connections if it has less than 30 peers and will refuse connections if it has 55.
  > **This value is important to performance.** When a new piece has completed download,
  > HAVE messages (see below) will need to be sent to most active peers.
  > As a result the cost of broadcast traffic grows in direct proportion to the number of peers. Above 25,
  > new peers are highly unlikely to increase download speed. UI designers are strongly
  > advised to make this obscure and hard to change as it is very rare to be useful to do so.
  >
  >  See: [Bittorrent Protocol Specification v1.0][specification]

  As required by the [specification], the queried peers will be **random**.

  <!-- links -->

  [specification]: https://wiki.theory.org/BitTorrentSpecification#Tracker_Response
  """

  import Ecto.Query

  alias YaBTT.Schema.Peer

  @type id :: integer() | binary()
  @type opts :: [mode: :compact | :no_peer_id | nil]

  @doc false
  @spec query(id(), opts()) :: [Peer.t()] | binary()
  def query(id, mode: :compact) do
    query(id, mode: :no_peer_id)
    |> Enum.reduce(<<>>, fn peer, acc ->
      with {:ok, {a, b, c, d}} <- Map.fetch(peer, "ip"),
           {:ok, port} <- Map.fetch(peer, "port") do
        acc <> <<a::8, b::8, c::8, d::8>> <> <<port::16>>
      else
        _ -> acc
      end
    end)
  end

  def query(id, mode: :no_peer_id) do
    do_query(id)
    |> select([p], %{"ip" => p.ip, "port" => p.port})
    |> YaBTT.Repo.all()
  end

  def query(id, _opts) do
    do_query(id)
    |> select([p], %{"peer id" => p.peer_id, "ip" => p.ip, "port" => p.port})
    |> YaBTT.Repo.all()
  end

  @spec do_query(id()) :: Ecto.Query.t()
  defp do_query(id) do
    from(
      p in Peer,
      inner_join: t in assoc(p, :torrents),
      on: t.id == ^id,
      order_by: fragment("RANDOM()"),
      limit: ^Application.get_env(:yabtt, :query_limit, 50)
    )
  end
end
