defmodule YaBTT.Query do
  @moduledoc false

  import Ecto.Query

  alias YaBTT.Schema.Peer

  @type id :: integer() | binary()
  @type opts :: [mode: :compact | :no_peer_id | nil]

  @doc false
  @spec query_peers(id(), opts()) :: [Peer.t()] | binary()
  def query_peers(id, mode: :compact) do
    query_peers(id, mode: :no_peer_id)
    |> Enum.reduce(<<>>, fn peer, acc ->
      with {:ok, {a, b, c, d}} <- Map.fetch(peer, "ip"),
           {:ok, port} <- Map.fetch(peer, "port") do
        acc <> <<a::8, b::8, c::8, d::8>> <> <<port::16>>
      else
        _ -> acc
      end
    end)
  end

  def query_peers(id, mode: :no_peer_id) do
    do_query(id)
    |> select([p], %{"ip" => p.ip, "port" => p.port})
    |> YaBTT.Repo.all()
  end

  def query_peers(id, _opts) do
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
      limit: 50
    )
  end
end
