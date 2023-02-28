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

  alias YaBTT.Schema.{Connection, Peer}

  @type id :: integer() | binary()
  @type opts :: YaBTT.Deco.config()

  @doc """
  Query the peers who hold the target torrent by `t:YaBTT.Deco.t/0`.
  """
  @spec query(YaBTT.Deco.t()) :: map()
  def query(%{ids: %{info_hash: i}, config: c}), do: query(i, c)

  @doc """
  Query the peers who hold the target torrent.

  We have implemented the [BitTorrent Tracker Protocol Extensions][protocol_extensions]. That means
  that we can use `:compact` and `:no_peer_id` for option `mode` to control the return of peer.

  You can see the specific meaning and [practical examples](#examples) of the options below.

  ## Mode

  - `:compact`: return a binary string of peers in compact format.

    In the mode, the peers with IPv4 list is replaced by a peers string with **6 bytes per peer**.
    For each peer, the **first 4 bytes are the IP address and the last 2 bytes are the port number**.
    The length of the whole peers will be a multiple of 6 (6 × **the number of peers in peers**).

    If the peers with Ipv6, the situation is similar, but the each peer is **18 bytes** (The first
    16 bytes are the IP address and the last 2 bytes are the port number).

  - `:no_peer_id`: return a list of peers **without** `peer id`.

    This option will be **ignored** if `:compact` mode is enabled.

  - `nil`: return a list of peers with **full information** (`ip`, `port` and the `peer id`).

  ## Parameters

  - `id`: the id of the target torrent
  - `opts`: the options to set the return format

  ## Examples

      iex> YaBTT.Query.Peers.query("info_hash", %{mode: :compact})

      iex> YaBTT.Query.Peers.query("info_hash", %{mode: :no_peer_id})

      iex> YaBTT.Query.Peers.query("info_hash", %{})
  """
  @spec query(id(), opts()) :: map()
  def query(info_hash, opts) do
    do_query(info_hash, opts) |> Map.put("interval", interval())
  end

  defp interval, do: Application.get_env(:yabtt, :interval, 1800)

  defp do_query(info_hash, %{mode: :compact}) do
    do_query(info_hash)
    |> select([p], {fragment("ip"), p.port})
    |> YaBTT.Repo.all()
    |> Enum.reduce({<<>>, <<>>}, fn {ip, port}, {ipv4, ipv6} ->
      case ip do
        <<_::32>> -> {ipv4 <> ip <> <<port::16>>, ipv6}
        <<_::128>> -> {ipv4, ipv6 <> ip <> <<port::16>>}
      end
    end)
    |> case do
      {ipv4, <<>>} -> %{"peers" => ipv4}
      {<<>>, ipv6} -> %{"peers6" => ipv6}
      {ipv4, ipv6} -> %{"peers" => ipv4, "peers6" => ipv6}
    end
  end

  defp do_query(info_hash, %{mode: :no_peer_id}) do
    do_query(info_hash)
    |> select([p], %{"ip" => p.ip, "port" => p.port})
    |> YaBTT.Repo.all()
    |> (&%{"peers" => &1}).()
  end

  defp do_query(info_hash, _opts) do
    do_query(info_hash)
    |> select([p], %{"peer id" => p.peer_id, "ip" => p.ip, "port" => p.port})
    |> YaBTT.Repo.all()
    |> (&%{"peers" => &1}).()
  end

  defp do_query(info_hash) do
    from(
      p in Peer,
      inner_join: c in Connection,
      on: c.torrent_info_hash == ^info_hash,
      where: p.id == c.peer_id and c.started == true,
      order_by: fragment("RANDOM()"),
      limit: ^Application.get_env(:yabtt, :query_limit, 50)
    )
  end
end
