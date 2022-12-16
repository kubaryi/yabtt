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
    # TODO: Implement the announce logic

    resp_msg =
      conn.params
      |> verify_req_params()
      |> verify_peer_event()
      |> handle_ip(conn.remote_ip)

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
  Verify the event parameter.

  ## Parameters

  - params: The parameters received from the request.

  ## Example

      iex> Tracker.Announce.verify_peer_event({:ok, %{"event" => "started"}})
      {:ok, %{"event" => "started"}}

      iex> Tracker.Announce.verify_peer_event({:ok, %{"event" => "non-compliant"}})
      :error

      iex> Tracker.Announce.verify_peer_event({:ok, %{}})
      {:ok, %{}}
  """
  @spec verify_peer_event({:ok, map()} | :error) :: {:ok, map()} | :error
  def verify_peer_event({:ok, params}) do
    case Map.fetch(params, "event") do
      {:ok, event} when event in ["started", "stopped", "completed"] -> {:ok, params}
      {:ok, _} -> :error
      :error -> {:ok, params}
    end
  end

  def verify_peer_event(:error), do: :error

  @doc """
  Verify and process IP addresses in params. If the IP address is not present in the params,
  use the remote IP address.

  ## Parameters

  - params: The parameters received from the request.
  - remote_ip: The remote IP address.

  ## Example

      iex> params = %{"info_hash" => "123", "peer_id" => "456", "ip" => "127.0.0.2"}
      iex> remote_ip = {127, 0, 0, 1}
      iex> Tracker.Announce.handle_ip({:ok, params}, remote_ip)
      {:ok, %{"info_hash" => "123", "peer_id" => "456", "ip" => "127.0.0.2"}}

      iex> params = %{"info_hash" => "123", "peer_id" => "456"}
      iex> remote_ip = {127, 0, 0, 1}
      iex> Tracker.Announce.handle_ip({:ok, params}, remote_ip)
      {:ok, %{"info_hash" => "123", "peer_id" => "456", "ip" => "127.0.0.1"}}
  """
  @spec handle_ip({:ok, map()} | :error, tuple()) :: {:ok, map()} | :error
  def handle_ip({:ok, params}, remote_ip) do
    ip =
      with {:ok, ip_str} <- Map.fetch(params, "ip"),
           {:ok, ip} <- :inet.parse_address(to_charlist(ip_str)) do
        ip
      else
        _ -> remote_ip
      end

    # TODO: Output ip as ip_address
    {:ok, Map.put(params, "ip", to_string(:inet.ntoa(ip)))}
  end

  def handle_ip(:error, _), do: :error

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
