defmodule Tracker.Announce do
  @moduledoc false

  @behaviour Plug
  import Plug.Conn

  @doc """
  Initializes the plug. This function is called once when the plug is compiled.

  This function pass the passed options `call/2`.

  ## Parameters

  - opts: The options passed to the plug.

  ## Return

  The options passed to the plug.
  """
  @spec init(Plug.opts()) :: Plug.opts()
  def init(opts), do: opts

  @doc """
  The main entry point for the plug. This function is called for every request.

  This function is responsible for:
  - Receive a report from peer
  - Update the track list
  - Return peers who hold the target torrent
  - Return other information

  ## Parameters

  - conn: The connection struct.
  - opts: The options passed to the plug.

  ## Return

  Processed connection structure.
  """
  @spec call(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def call(conn, _opts) do
    resp_msg =
      with {:ok, params} <- verify_req_params(conn.params) do
        import Tracker.Track

        track = to_track(params, conn.remote_ip)

        # TODO: Implement the announce logic

        {:ok, %{track | ip: to_string(:inet.ntoa(track.ip))}}
      end

    conn
    |> put_resp_content_type("plain/text")
    |> put_resp_msg(resp_msg)
    |> send_resp()
  end

  @doc """
  Verify the required parameters.

  ## Parameters

  - params: The parameters received from the request.

  ## Example

  if all required parameters are present, return `{:ok, map()}`.

      iex> %{
      ...> "info_hash" => "123",
      ...> "peer_id" => "456",
      ...> "left" => "789",
      ...> "downloaded" => "0",
      ...> "uploaded" => "0",
      ...> "port" => "6881"
      ...> } |> Tracker.Announce.verify_req_params()
      {:ok,
        %{"info_hash" => "123",
          "peer_id" => "456",
          "left" => "789",
          "downloaded" => "0",
          "uploaded" => "0",
          "port" => "6881"
        }
      }

  if any required parameters are missing, return `:error`.

      iex> %{"info_hash" => "123", "peer_id" => "456"}
      ...> |> Tracker.Announce.verify_req_params()
      :error
  """
  @spec verify_req_params(map()) :: {:ok, map()} | :error
  def verify_req_params(params) do
    fields = ["info_hash", "peer_id", "left", "downloaded", "uploaded", "port"]
    contains_fields? = fn keys -> Enum.all?(fields, &(&1 in keys)) end

    if contains_fields?.(Map.keys(params)), do: {:ok, params}, else: :error
  end

  @doc """
  Bind the response message to the connection struct. All the message will be encoded as
  [bencoding](http://www.bittorrent.org/beps/bep_0003.html#bencoding) with `Bento.encode/2`.

  ## Parameters

  - conn: The connection struct.
  - msg: The response message.

  ## Example

      iex> conn = %Plug.Conn{}
      iex> msg = {:ok, %{"interval" => 1800, "min interval" => 1800, "peers" => []}}
      iex> Tracker.Announce.put_resp_msg(conn, msg)

  """
  @spec put_resp_msg(Plug.Conn.t(), {:ok, Bento.Encoder.t()} | :error) :: Plug.Conn.t()
  def put_resp_msg(conn, {:ok, data}) do
    case Bento.encode(data) do
      {:ok, msg} -> resp(conn, 200, msg)
      {:error, _} -> put_resp_msg(conn, :error)
    end
  end

  def put_resp_msg(conn, :error) do
    resp(conn, 400, "d14:failure reason15:invalid requeste")
  end
end
