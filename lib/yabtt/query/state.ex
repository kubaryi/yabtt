defmodule YaBTT.Query.State do
  @moduledoc """
  This module is used to query the state from the `YaBTT.Schema.Connection`.
  """

  import Ecto.Query

  alias YaBTT.Schema.{Connection, Torrent}

  @type info_hash :: binary()
  @type t :: %{info_hash() => %{binary() => non_neg_integer()}}

  @doc """
  Query the state with `t:info_hash/0` from the `YaBTT.Schema.Connection`.

  Use one or more given `t:info_hash/0` to query the following information
  from the `YaBTT.Schema.Connection`:

  * `complete` - The number of active peers that have completed downloading.

    calculate by `left <= 0 AND event == 1`.

  * `incomplete` - The number of active peers that have not completed downloading.

    calculate by `left > 0 AND event == 1`.

  * `downloaded` - The number of peers that have ever completed downloading.

    calculate by `left <= 0 OR event == -1`.

  > #### About the `event` {: .info}
  >
  > The `event` will store as an integer (`t:YaBTT.Types.Event.io_event/0`) in database.
  >
  > Since we use `Ecto.Query.API.fragment/1` and the [`CASE WHEN` syntax][case_when] to direct
  > query information from the database, so we have to compare the `event` with the integer.
  >
  > [More information about event](`YaBTT.Types.Event`).

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
  @spec query([info_hash()]) :: [t() | nil]
  def query(info_hashs) do
    from(c in Connection)
    |> join(:inner, [c], t in Torrent, on: c.torrent_id == t.id)
    |> where([_c, t], t.info_hash in ^info_hashs)
    |> group_by([c, t], t.info_hash)
    |> select([c, t], %{
      t.info_hash => %{
        # The event will store as an integer (-1, 0, or 1) in database.
        "complete" => count(fragment("CASE WHEN left <= 0 AND event == 1 THEN 1 END")),
        "incomplete" => count(fragment("CASE WHEN left > 0 AND event == 1 THEN 1 END")),
        "downloaded" => count(fragment("CASE WHEN left <= 0 OR event == -1 THEN 1 END"))
      }
    })
    |> YaBTT.Repo.all()
  end
end
