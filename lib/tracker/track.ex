defmodule Tracker.Track do
  @moduledoc """
  Represents a tracker request.

  The tracker request is sent to the tracker by the client to inform it of the
  client's current status. The tracker responds with a list of peers that the
  client can connect to.

  ## Example
      iex> %Tracker.Track{
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

  @type t :: %__MODULE__{
          info_hash: String.t(),
          peer_id: String.t(),
          ip: :inet.ip_address(),
          port: integer(),
          uploaded: integer(),
          downloaded: integer(),
          left: integer(),
          event: String.t() | nil
        }

  @doc """
  Convert the map to Track struct.

  **Note: It won't check @enforce_keys, except the `event`**

  ## Parameters

  - params: The map to be converted.

  ## Example

      iex> track = %{
      ...>   "info_hash" => "aaaaaaaaaaaaaaaaaaaa",
      ...>   "event" => "non-compliant",
      ...>   } |> Tracker.Track.to_track()
      iex> track.info_hash
      "aaaaaaaaaaaaaaaaaaaa"
      iex> track.ip
      nil
      iex> track.event
      nil
  """
  @spec to_track(map()) :: t()
  def to_track(params) do
    map_with_atom_keys =
      for {key, value} <- params, into: %{} do
        {String.to_existing_atom(key), value}
      end

    struct(__MODULE__, map_with_atom_keys) |> handle_event()
  end

  @doc """
  Convert the map to Track struct and handle the IP address.

  ## Parameters

  - params: The map to be converted.
  - ip: The IP address of the client.

  ## Example

      iex> track = %{} |> Tracker.Track.to_track({1, 2, 3, 4})
      iex> track.ip
      {1, 2, 3, 4}
  """
  @spec to_track(map, :inet.ip_address()) :: t()
  def to_track(params, ip), do: to_track(params) |> handle_ip(ip)

  @doc """
  Verify the event in Track struct.

  ## Parameters

  - track: The Track struct.

  ## Example

      iex> track = struct(Tracker.Track, event: "started")
      ...> |> Tracker.Track.handle_event()
      iex> track.event
      "started"

      iex> track = struct(Tracker.Track, event: "non-compliant")
      ...> |> Tracker.Track.handle_event()
      iex> track.event
      nil

      iex> track = struct(Tracker.Track, %{})
      ...> |> Tracker.Track.handle_event()
      iex> track.event
      nil
  """
  @spec handle_event(t()) :: t()
  def handle_event(track) do
    available = ["started", "stopped", "completed", nil]

    if track.event in available, do: track, else: %{track | event: nil}
  end

  @doc """
  Verify and process IP addresses in Track struct. If the IP address is not present in the Track struct,
  use the remote IP address.

  ## Parameters

  - track: The Track struct.
  - remote_ip: The remote IP address.

  ## Example

      iex> remote_ip = {127, 0, 0, 1}
      iex> track = struct(Tracker.Track, ip: "127.0.0.2")
      ...> |> Tracker.Track.handle_ip(remote_ip)
      iex> track.ip
      {127, 0, 0, 2}

      iex> remote_ip = {127, 0, 0, 1}
      iex> track = struct(Tracker.Track, %{})
      ...> |> Tracker.Track.handle_ip(remote_ip)
      iex> track.ip
      {127, 0, 0, 1}
  """
  @spec handle_ip(t(), :inet.ip_address()) :: t()
  def handle_ip(track, remote_ip) do
    case :inet.parse_address(to_charlist(track.ip)) do
      {:ok, ip} -> %{track | ip: ip}
      _ -> %{track | ip: remote_ip}
    end
  end
end
