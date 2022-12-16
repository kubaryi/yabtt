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
      |> verify_req_params(["info_hash", "peer_id", "left", "downloaded", "uploaded", "port"])

    conn
    |> put_resp_content_type("plain/text")
    |> put_resp_msg(resp_msg)
    |> send_resp()
  end

  @doc """
  Verify the required parameters.

  ## Parameters

  - params: The parameters received from the request.
  - fields: The required parameters.

  ## Example

  if all required parameters are present, return `{:ok, map()}`.

      iex> params = %{"info_hash" => "123", "peer_id" => "456", "left" => "789"}
      iex> fields = ["info_hash", "peer_id", "left"]
      iex> verify_req_params(params, fields)
      {:ok, %{"info_hash" => "123", "peer_id" => "456", "left" => "789"}}

  if any required parameters are missing, return `:error`.

      iex> params = %{"info_hash" => "123", "peer_id" => "456"}
      iex> fields = ["info_hash", "peer_id", "left"]
      iex> verify_req_params(params, fields)
      :error
  """
  @spec verify_req_params(map(), [String.t()]) :: {:ok, map()} | :error
  def verify_req_params(params, fields) do
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
      iex> put_resp_msg(conn, msg)
      %Plug.Conn{...}
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
