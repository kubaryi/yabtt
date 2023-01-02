defmodule YaBTT.Server.Scrape do
  @moduledoc false

  @behaviour Plug
  import Plug.Conn

  @doc false
  @spec init(Plug.opts()) :: Plug.opts()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def call(conn, _opts) do
    resp_msg = YaBTT.query_state([""]) |> Bento.encode()

    conn
    |> put_resp_content_type("text/plain")
    |> put_resp_msg(resp_msg)
    |> send_resp()
  end

  @type resp_msg :: {:ok, String.t()} | {:error, term()}

  @spec put_resp_msg(Plug.Conn.t(), resp_msg()) :: Plug.Conn.t()
  defp put_resp_msg(conn, {:ok, msg}), do: resp(conn, 200, msg)
  defp put_resp_msg(conn, {:error, _}), do: resp(conn, 400, "")
end
