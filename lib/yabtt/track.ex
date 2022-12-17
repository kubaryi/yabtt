defmodule YaBTT.Tracked do
  @moduledoc """
  Represents a tracker request.

  The tracker request is sent to the tracker by the client to inform it of the
  client's current status. The tracker responds with a list of peers that the
  client can connect to.

  ## Example
      iex> %YaBTT.Tracked{
      ...>   info_hash: "aaaaaaaaaaaaaaaaaaaa",
      ...>   peer_id: "aaaaaaaaaaaaaaaaaaaa",
      ...>   ip: "192.168.0.1",
      ...>   port: 6881,
      ...>   uploaded: 0,
      ...>   downloaded: 100,
      ...>   left: 0,
      ...>   event: "started"
      ...> }
  """

  @enforce_keys [:info_hash, :peer_id, :ip, :port, :uploaded, :downloaded, :left]
  defstruct [:info_hash, :peer_id, :ip, :port, :uploaded, :downloaded, :left, :event]

  @type ip_addr :: :inet.ip_address()

  @type t :: %__MODULE__{
          info_hash: String.t(),
          peer_id: String.t(),
          ip: ip_addr(),
          port: integer(),
          uploaded: integer(),
          downloaded: integer(),
          left: integer(),
          event: String.t() | nil
        }
end

defprotocol YaBTT.Track do
  @moduledoc """
  Protocol and implementations to convert the trackable to `YaBTT.Tracked.t()`.
  """

  alias YaBTT.Tracked

  @type trackable :: map() | Tracked.t()
  @type ip_addr :: :inet.ip_address()
  @type t :: Tracked.t() | {:ok, Tracked.t()} | :error

  @doc """
  Convert the trackable to Track struct.

  ## Parameters

  - value: The trackable to be converted.
  - ip: The ip address of the client.

  ## Example

  Standardized the `Track` struct. It will automatically convert the `ip` to
  the `:inet.ip_address()` type (`ip` in `Track` has a higher priority).
  And it will also check if the `event` is a valid event, if not, it will be
  set to `nil`.

      iex> track = %YaBTT.Tracked{
      ...>   info_hash: "aaaaaaaaaaaaaaaaaaaa",
      ...>   peer_id: "aaaaaaaaaaaaaaaaaaaa",
      ...>   ip: "192.168.0.1",
      ...>   port: 6881,
      ...>   uploaded: 0,
      ...>   downloaded: 100,
      ...>   left: 0,
      ...>   event: "started"
      ...> } |> YaBTT.Track.track({1, 2, 3, 4})
      iex> track.info_hash
      "aaaaaaaaaaaaaaaaaaaa"
      iex> track.ip
      {192, 168, 0, 1}
      iex> track.event
      "started"

  For the `Track`, it will not check the `@enforce_keys`.

      iex> track = struct(YaBTT.Tracked, %{}) |> YaBTT.Track.track({1, 2, 3, 4})
      iex> track.info_hash
      nil

  For the `Map`, it will check the `@enforce_keys`. If the `Map` is valid, it
  will convert the `Map` to a `Track` struct. And it will wrap the `Track` in
  `{:ok, track}`.

      iex> {:ok, track} = %{
      ...>   "info_hash" => "aaaaaaaaaaaaaaaaaaaa",
      ...>   "peer_id" => "aaaaaaaaaaaaaaaaaaaa",
      ...>   "port" => 6881,
      ...>   "uploaded" => 0,
      ...>   "downloaded" => 100,
      ...>   "left" => 0,
      ...>   "event" => "non-compliant",
      ...>   } |> YaBTT.Track.track({1, 2, 3, 4})
      iex> track.info_hash
      "aaaaaaaaaaaaaaaaaaaa"
      iex> track.ip
      {1, 2, 3, 4}
      iex> track.event
      nil

  If the `Map` is not valid, it will return `:error`.

      iex> YaBTT.Track.track(%{}, {1, 2, 3, 4})
      :error
  """
  @spec track(trackable(), ip_addr) :: t()
  def track(value, ip)
end

defimpl YaBTT.Track, for: YaBTT.Tracked do
  @moduledoc """
  Implementation of `YaBTT.Track` for `YaBTT.Tracked.t()`.
  """

  alias YaBTT.Tracked
  alias YaBTT.Track

  @doc """
  Standardized the `Track` struct.

  **Note: This function will not check @enforce_keys.**

  ## Parameters

  - value: The `Track` to be standardized.
  - ip: The ip address of the client.

  ## Example

      iex> track = struct(YaBTT.Tracked, info_hash: "aaaaaaaaaaaaaaaaaaaa")
      ...> |> YaBTT.Track.YaBTT.Tracked.track({1, 2, 3, 4})
      iex> track.info_hash
      "aaaaaaaaaaaaaaaaaaaa"
      iex> track.ip
      {1, 2, 3, 4}
      iex> track.event
      nil
  """
  @spec track(Tracked.t(), Track.ip_addr()) :: Tracked.t()
  def track(track, ip), do: track |> handle_event() |> handle_ip(ip)

  @spec handle_event(Tracked.t()) :: Tracked.t()
  defp handle_event(track) do
    available = ["started", "stopped", "completed", nil]

    if track.event in available, do: track, else: %{track | event: nil}
  end

  @spec handle_ip(Tracked.t(), Track.ip_addr()) :: Tracked.t()
  defp handle_ip(track, remote_ip) do
    case :inet.parse_address(to_charlist(track.ip)) do
      {:ok, ip} -> %{track | ip: ip}
      _ -> %{track | ip: remote_ip}
    end
  end
end

defimpl YaBTT.Track, for: Map do
  @moduledoc """
  Implementation of `YaBTT.Track` for `Map`.
  """

  alias YaBTT.Tracked
  alias YaBTT.Track

  @type map_with_string_keys :: %{String.t() => String.t()}
  @type map_with_atom_keys :: %{atom() => String.t()}

  @doc """
  Convert the map to Track struct.

  ## Parameters

  - params: The map to be converted.
  - ip: The ip address of the client.

  ## Example

      iex> YaBTT.Track.Map.track(%{}, {1, 2, 3, 5})
      :error
  """
  @spec track(map_with_string_keys, Track.ip_addr()) :: Track.t()
  def track(params, ip) do
    if contains_enforce_keys(Map.keys(params)) do
      map_with_atom_keys = simplification(params)

      struct(Tracked, map_with_atom_keys)
      |> Track.YaBTT.Tracked.track(ip)
      |> (fn track -> {:ok, track} end).()
    else
      :error
    end
  end

  @spec simplification(map_with_string_keys()) :: map_with_atom_keys()
  defp simplification(map_with_string_keys) do
    for {key, value} <- map_with_string_keys, into: %{} do
      {String.to_existing_atom(key), value}
    end
  end

  @spec contains_enforce_keys([String.t()]) :: boolean()
  defp contains_enforce_keys(keys) do
    enforce_keys = ["info_hash", "peer_id", "left", "downloaded", "uploaded", "port"]
    Enum.all?(enforce_keys, &(&1 in keys))
  end
end
