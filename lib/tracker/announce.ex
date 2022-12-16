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

    conn
    |> put_resp_content_type("plain/text")
    |> put_resp_msg({:ok, "OK"})
    |> send_resp()
  end

  @spec put_resp_msg(Plug.Conn.t(), {:ok, Bento.Encoder.t()} | :error) :: Plug.Conn.t()
  def put_resp_msg(conn, {:ok, struct}) do
    case Bento.encode(struct) do
      {:ok, msg} -> resp(conn, 200, msg)
      {:error, _} -> put_resp_msg(conn, :error)
    end
  end

  def put_resp_msg(conn, :error) do
    resp(conn, 400, "d14:failure reason15:invalid requeste")
  end
end

defmodule Tracker.InvalidRequeste do
  defexception message: "invalid requeste"
end
