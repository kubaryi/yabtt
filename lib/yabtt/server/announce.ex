defmodule YaBTT.Server.Announce do
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
    resp_msg = {:ok, "hello world"}

    conn
    |> put_resp_content_type("plain/text")
    |> put_resp_msg(resp_msg)
    |> send_resp()
  end

  @type resp_msg :: {:ok, Bento.Encoder.t()} | {:error, String.t()} | any()

  @doc """
  Bind the response message to the connection struct. All the message will be encoded as
  [bencoding](http://www.bittorrent.org/beps/bep_0003.html#bencoding) with `Bento.encode/2`.

  ## Parameters

  - conn: The connection struct.
  - msg: The response message.

  ## Example

      iex> conn = %Plug.Conn{}
      iex> msg = {:ok, %{"interval" => 1800, "min interval" => 1800, "peers" => []}}
      iex> YaBTT.Server.Announce.put_resp_msg(conn, msg)

  """
  @spec put_resp_msg(Plug.Conn.t(), resp_msg()) :: Plug.Conn.t()
  def put_resp_msg(conn, {:ok, data}) do
    case Bento.encode(data) do
      {:ok, msg} -> resp(conn, 200, msg)
      {:error, _} -> put_resp_msg(conn, :error)
    end
  end

  def put_resp_msg(conn, {:error, err_msg}) do
    # The `Bento.encode/2` has a bug that it will raise an exception when the
    # input is a map. So we have to use `Bento.Encoder.encode/` instead.
    # See: https://github.com/folz/bento/pull/13
    Bento.Encoder.encode(%{"failure reason" => err_msg})
    |> IO.iodata_to_binary()
    |> (&resp(conn, 400, &1)).()
  end

  def put_resp_msg(conn, _) do
    resp(conn, 500, "d14:failure reason22:unknown internal errore")
  end
end
