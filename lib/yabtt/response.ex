defprotocol YaBTT.Response do
  @moduledoc """
  The `YaBTT.Response` protocol is used to extract a `YaBTT.Schema.Torrent` or
  `YaBTT.Schema.Peer` into a `map()`. This is used to provide a unified interface
  for HTTP responses.

  ## Parameters

    * `data` - The `YaBTT.Schema.Torrent` or `YaBTT.Schema.Peer` to extract.

  ## Examples

      iex> alias YaBTT.Schema.{Torrent, Peer}
      iex> torrent = %Torrent{id: 1, peers: [%Peer{id: 1}]}
      iex> resp = YaBTT.Response.extract(torrent)
      iex> resp.peers |> Enum.to_list()
      [%{"ip" => nil, "peer id" => nil, "port" => nil}]
      iex> resp.interval
      3600

      iex> alias YaBTT.Schema.Peer
      iex> peer = %Peer{peer_id: "-TR14276775888084598", port: 6881, ip: "1.2.3.4"}
      iex> YaBTT.Response.extract(peer)
      %{"ip" => "1.2.3.4", "peer id" => "-TR14276775888084598", "port" => 6881}
  """

  alias YaBTT.Schema.{Torrent, Peer}

  @type data :: Torrent.t() | Peer.t()
  @type opts :: [compact: 0 | 1, no_peer_id: 0 | 1]

  @doc """
  Extracts the `YaBTT.Schema.Torrent` or `YaBTT.Schema.Peer` into a `map()`.

  We have implemented the [BitTorrent Tracker Protocol Extensions][protocol_extensions].
  That means that we can control the return of peer through the options `compact` and
  `no_peer_id`.

  You can see the [specific meaning](#options) and [practical examples](#examples)
  of the options below.

  ## Parameters

    * `data` - The `YaBTT.Schema.Torrent` or `YaBTT.Schema.Peer` to extract.
    * `opts` - The [options](#options) to use when extracting the data.

  ## Options

    * `compact` - If `1`, the `peers` key will be a binary string of the peers.
      and this option will cover the `no_peer_id` option.
    * `no_peer_id` - If `1`, the `peer id` key will not be included in the response.
    * otherwise - The `peer id` key will be included in the response.

  > #### Warning {: .warning}
  >
  > The compact mode can't work with **IPv6 addresses**.
  >
  > If the Client sends a request with `compact == 1` and the IP address of the peer
  > is an IPv6 address, we will handle according with actual situation:
  >
  > * If the `no_peer_id == 1`, we will degenerate to "no_peer_id mode".
  > * Otherwise, we will return the full peer information.

  ## Examples

      iex> alias YaBTT.Schema.Peer
      iex> peer = %Peer{peer_id: "-TR14276775888084598", port: 2001, ip: "192.168.24.52"}
      iex> YaBTT.Response.extract(peer, compact: 1, no_peer_id: 1)
      <<192, 168, 24, 52, 7, 209>>

      iex> alias YaBTT.Schema.Peer
      iex> peer = %Peer{peer_id: "-TR14276775888084598", port: 6881, ip: "1.2.3.4"}
      iex> YaBTT.Response.extract(peer, compact: 0, no_peer_id: 1)
      %{ip: "1.2.3.4", port: 6881}

      iex> alias YaBTT.Schema.Peer
      iex> peer = %Peer{peer_id: "-TR14276775888084598", port: 6881, ip: "2607:f0d0:1002:51::4"}
      iex> YaBTT.Response.extract(peer, compact: 1, no_peer_id: 1)
      %{ip: "2607:f0d0:1002:51::4", port: 6881}

      iex> alias YaBTT.Schema.Peer
      iex> peer = %Peer{peer_id: "-TR14276775888084598", port: 6881, ip: "2607:f0d0:1002:51::4"}
      iex> YaBTT.Response.extract(peer, compact: 1, no_peer_id: 0)
      %{"ip" => "2607:f0d0:1002:51::4", "peer id" => "-TR14276775888084598", "port" => 6881}

  <!-- Links -->

  [protocol_extensions]: https://wiki.theory.org/BitTorrentTrackerExtensions
  """
  @spec extract(data(), opts()) :: map() | binary()
  def extract(data, opts \\ [compact: 0, no_peer_id: 0])
end
