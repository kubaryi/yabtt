defprotocol Bucket.Storable do
  @moduledoc """
  Protocol and implementations to convert the storable to a storable format.
  """

  alias YaBTT.Tracked

  @type storable :: Tracked.t()
  @type peer :: {String.t(), integer(), integer()}
  @type state :: {integer(), integer(), integer()}
  @type t :: [String.t() | peer() | state()]

  @doc """
  Convert the storable to a storable format.

  ## Parameters

  - value: The storable to be converted.

  ## Example

      iex> %YaBTT.Tracked{
      ...>   info_hash: "info_hash",
      ...>   peer_id: "peer_id",
      ...>   ip: {1, 2, 3, 4},
      ...>   port: 6881,
      ...>   uploaded: 0,
      ...>   downloaded: 100,
      ...>   left: 0,
      ...>   event: "started"
      ...> } |> Bucket.Storable.store()
      ["info_hash", {"peer_id", {1, 2, 3, 4}, 6881}, {100, 0, 0}, "started"]
  """
  @spec store(storable()) :: t()
  def store(value)
end

defimpl Bucket.Storable, for: YaBTT.Tracked do
  @moduledoc """
  Implementation of `Bucket.Storable` for `YaBTT.Tracked`.
  """

  alias YaBTT.Tracked

  @doc """
  Convert the `Tracked` struct to a storable format.

  ## Parameters

  - track: The `Tracked` struct to be converted.

  ## Example

      iex> struct(YaBTT.Tracked, %{})
      ...> |> Bucket.Storable.YaBTT.Tracked.store()
      [nil, {nil, nil, nil}, {nil, nil, nil}, nil]
  """
  @spec store(Tracked.t()) :: Bucket.Storable.t()
  def store(track) do
    peer = {track.peer_id, track.ip, track.port}
    state = {track.downloaded, track.uploaded, track.left}

    [track.info_hash, peer, state, track.event]
  end
end
