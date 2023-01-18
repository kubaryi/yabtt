defmodule YaBTT.Query.State do
  @moduledoc """
  This module is used to query the state from the `YaBTT.Schema.Connection`.
  """

  import Ecto.Query

  alias YaBTT.Schema.{Connection, Torrent}

  @type info_hash :: binary()
  @type t :: %{binary() => %{info_hash() => %{binary() => non_neg_integer()} | %{}}}

  @spec case_when(term(), then: term()) :: term()
  defmacrop case_when(condition, then: clauses) do
    quote do
      fragment(unquote("CASE WHEN #{condition} THEN #{clauses} END"))
    end
  end

  @doc """
  Query the state with `t:info_hash/0` from the `YaBTT.Schema.Connection`.

  Use one or more given `t:info_hash/0` to query the following information
  from the `YaBTT.Schema.Connection`:

  * `complete` - The number of active peers that have completed downloading.
  * `incomplete` - The number of active peers that have not completed downloading.
  * `downloaded` - The number of peers that have ever completed downloading.

  Then we will return a `t:t/0` as required by the [specification][scrape_1].

  ## References

  - [Tracker Protocol Extension: Scrape][scrape_1]
  - [Tracker 'scrape' Convention][scrape_2]

  ## Examples

      iex> YaBTT.Query.State.query(["info_hash_1", "info_hash_2"])

  <!-- links -->

  [case_when]: https://stackoverflow.com/questions/17975229/using-sql-count-in-a-case-statement
  [scrape_1]: http://bittorrent.org/beps/bep_0048.html
  [scrape_2]: https://wiki.theory.org/BitTorrentSpecification#Tracker_.27scrape.27_Convention
  """
  @spec query([info_hash()]) :: t()
  def query(info_hashs) do
    from(c in Connection)
    |> join(:inner, [c], t in Torrent, on: c.torrent_id == t.id)
    |> where([_c, t], t.info_hash in ^info_hashs)
    |> group_by([c, t], t.info_hash)
    |> select([c, t], {t.info_hash,
     %{
       # Query with the `CASE WHEN ... THEN ... END` syntax
       "complete" => count(case_when("started AND completed", then: 1)),
       "incomplete" => count(case_when("started AND NOT completed", then: 1)),
       "downloaded" => count(case_when("completed", then: 1))
     }})
    |> YaBTT.Repo.all()
    |> (&%{"files" => Map.new(&1)}).()
  end

  @spec query :: map()
  def query do
    from(c in Connection,
      select: %{
        # Connections
        active: count(case_when("started", then: 1)),
        seeders: count(case_when("started AND completed", then: 1)),
        leechers: count(case_when("started AND NOT completed", then: 1)),
        completed: count(case_when("completed", then: 1)),
        total: count(),
        # Torrents
        torrents: count(c.torrent_id, :distinct),
        # Peers
        peers: count(c.peer_id, :distinct)
      }
    )
    |> YaBTT.Repo.one()
  end
end
