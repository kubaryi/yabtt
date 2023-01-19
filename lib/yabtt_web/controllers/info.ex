defmodule YaBTTWeb.Controllers.Info do
  @moduledoc false

  @behaviour Plug

  import Plug.Conn

  @doc false
  @spec init(Plug.opts()) :: Plug.opts()
  def init(opts), do: opts

  @doc false
  @spec call(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def call(conn, _opts) do
    {result, _} = YaBTT.Query.State.query() |> quote_eex()

    conn
    |> put_resp_content_type("text/html")
    |> resp(200, result)
    |> send_resp()
  end

  @eex_file Path.absname("../templates/info.html.heex", __DIR__)

  @spec quote_eex(state) :: {binary(), [asssigs: [state: state]]}
        when state: map()
  defp quote_eex(data) do
    EEx.compile_file(@eex_file, trim: true) |> Code.eval_quoted(assigns: [state: data])
  end
end
