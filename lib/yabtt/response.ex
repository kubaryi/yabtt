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
  Extracts the `YaBBT.Schema.Torrent` or `YaBTT.Schema.Peer` into a `map()`.
  """
  @spec extract(data(), opts()) :: map() | binary()
  def extract(data, opts \\ [compact: 0, no_peer_id: 0])
end
