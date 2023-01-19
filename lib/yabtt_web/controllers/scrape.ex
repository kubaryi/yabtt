defmodule YaBTTWeb.Controllers.Scrape do
  @moduledoc """
  A `Plug` to handle route `/scrape`.

  The original [BitTorrent Protocol Specification](http://www.bittorrent.org/beps/bep_0003.html) defines
  one exchange between a client and a tracker referred to as an announce. In order to build responsive user
  interfaces, clients desired an additional way to query metadata about swarms in bulk. The exchange that
  fetches this metadata for the clients is referred to as a scrape.

  It should be noted that scrape exchanges have no effect on a peer's participation in a swarm.

  Learn more about [Tracker Protocol Extension: Scrape](http://bittorrent.org/beps/bep_0048.html).

  ## Examples

  For reference, we have prepared a [more detailed actual cases](./examples-and-screenshots.html#call-scrape-with-info_hash-list)
  of call routing `/scrape`.

  ## Scrape Request

  The query string should be like:

  ```plaintext
  info_hash=Nf%22v%BA%CA%0F%DBk%D6%0Bv%17%8C%D1%19%D1%05%00%13&info_hash=%124Vx%9A%BC%DE%F1%23Eg%89%AB%CD%EF%124Vx%9A
  ```

  Notice that the `info_hash` need to be encoded to [RFC1738](http://www.faqs.org/rfcs/rfc1738.html).

  ## Scrape Response

  The response to a successful request is a bencoded dictionary containing one key-value pair: the key files
  with the value being a dictionary of the 20-byte string representation of an infohash paired with a dictionary
  of swarm metadata. The fields found in the swarm metadata dictionary are as follows:

  * `complete` - The number of active peers that have completed downloading.
  * `incomplete` - The number of active peers that have not completed downloading.
  * `downloaded` - The number of peers that have ever completed downloading.
  """

  @behaviour Plug

  import YaBTTWeb.Controllers.Announce
  import Plug.Conn

  @doc """
  Initializes the plug.
  """
  @spec init(Plug.opts()) :: Plug.opts()
  def init(opts), do: opts

  @doc """
  The main entry point for the plug.
  """
  @spec call(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def call(conn, _opts) do
    res = fetch_info_hashs(conn.query_string) |> YaBTT.query_state()

    conn
    |> put_resp_content_type("text/plain")
    |> put_resp_msg({:ok, res})
    |> send_resp()
  end

  @spec fetch_info_hashs(String.t()) :: [String.t()]
  defp fetch_info_hashs(call) do
    String.splitter(call, "&", trim: true)
    |> Enum.reduce([], fn param, acc ->
      case String.split_at(param, 10) do
        {"info_hash=", v} -> [URI.decode(v) | acc]
        _ -> acc
      end
    end)
  end
end
