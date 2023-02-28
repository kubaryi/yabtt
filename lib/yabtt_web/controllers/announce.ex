defmodule YaBTTWeb.Controllers.Announce do
  @moduledoc """
  The Announce controller for the YaBTT application.
  """

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
    resp_msg = YaBTT.insert_or_update(conn) |> YaBTT.query_peers()

    conn
    |> put_resp_content_type("plain/text")
    |> put_resp_msg(resp_msg)
    |> send_resp()
  end

  @type resp_msg :: YaBTT.t(term()) | :error

  defguardp is_changeset(changeset) when is_struct(changeset, Ecto.Changeset)

  @doc """
  Bind the response message to the connection struct. All the message will be encoded as
  [bencoding](http://www.bittorrent.org/beps/bep_0003.html#bencoding) with `Bento.encode/2`.

  ## Parameters

  - conn: The connection struct.
  - msg: The response message.

  ## Example

      iex> conn = %Plug.Conn{}
      iex> msg = {:ok, %{"interval" => 1800, "peers" => []}}
      iex> conn = YaBTTWeb.Controllers.Announce.put_resp_msg(conn, msg)
      iex> conn.resp_body
      "d8:intervali1800e5:peerslee"

      iex> conn = %Plug.Conn{}
      iex> msg = {:error, "Some error message"}
      iex> conn = YaBTTWeb.Controllers.Announce.put_resp_msg(conn, msg)
      iex> conn.resp_body
      "d14:failure reason18:Some error messagee"

      iex> conn = %Plug.Conn{}
      iex> conn = YaBTTWeb.Controllers.Announce.put_resp_msg(conn, :error)
      iex> conn.resp_body
      "d14:failure reason22:unknown internal errore"
  """
  @spec put_resp_msg(Plug.Conn.t(), resp_msg()) :: Plug.Conn.t()
  def put_resp_msg(conn, {:ok, data}) do
    case Bento.encode(data) do
      {:ok, msg} -> resp(conn, 200, msg)
      {:error, _} -> put_resp_msg(conn, :error)
    end
  end

  def put_resp_msg(conn, {:error, changeset}) when is_changeset(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
    |> case do
      msg -> put_resp_msg(conn, {:error, msg})
    end
  end

  def put_resp_msg(conn, {:error, msg}) do
    resp(conn, 200, %{"failure reason" => msg} |> Bento.encode!())
  end

  def put_resp_msg(conn, {:error, _name, changeset, _multi}) do
    put_resp_msg(conn, {:error, changeset})
  end

  def put_resp_msg(conn, _) do
    resp(conn, 500, "d14:failure reason22:unknown internal errore")
  end
end
