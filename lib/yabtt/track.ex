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
  @moduledoc false

  @type trackable :: map()
  @type ip_addr :: :inet.ip_address()
  @type t :: YaBTT.Tracked.t() | :error

  @spec track(trackable(), ip_addr) :: t()
  def track(value, ip)
end

defimpl YaBTT.Track, for: Map do
  @moduledoc false

  @doc """
  Convert the map to Track struct.

  ## Parameters

  - params: The map to be converted.

  ## Example

      iex> track = %{
      ...>   "info_hash" => "aaaaaaaaaaaaaaaaaaaa",
      ...>   "peer_id" => "aaaaaaaaaaaaaaaaaaaa",
      ...>   "ip" => "1.2.3.4",
      ...>   "port" => 6881,
      ...>   "uploaded" => 0,
      ...>   "downloaded" => 100,
      ...>   "left" => 0,
      ...>   "event" => "non-compliant",
      ...>   } |> YaBTT.Track.track({1, 2, 3, 5})
      iex> track.info_hash
      "aaaaaaaaaaaaaaaaaaaa"
      iex> track.ip
      {1, 2, 3, 4}
      iex> track.event
      nil

      iex> track = %{} |> YaBTT.Track.track({1, 2, 3, 5})
      :error
  """
  @spec track(map, :inet.ip_address()) :: YaBTT.Track.t()
  def track(params, ip) do
    if contains_enforce_keys(Map.keys(params)) do
      map_with_atom_keys = simplification(params)

      struct(YaBTT.Tracked, map_with_atom_keys)
      |> handle_event()
      |> handle_ip(ip)
    else
      :error
    end
  end

  @type map_with_string_keys :: %{String.t() => String.t()}
  @type map_with_atom_keys :: %{atom() => String.t()}

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

  @spec handle_event(YaBTT.Tracked.t()) :: YaBTT.Tracked.t()
  defp handle_event(track) do
    available = ["started", "stopped", "completed", nil]

    if track.event in available, do: track, else: %{track | event: nil}
  end

  @spec handle_ip(YaBTT.Tracked.t(), :inet.ip_address()) :: YaBTT.Tracked.t()
  defp handle_ip(track, remote_ip) do
    case :inet.parse_address(to_charlist(track.ip)) do
      {:ok, ip} -> %{track | ip: ip}
      _ -> %{track | ip: remote_ip}
    end
  end
end
