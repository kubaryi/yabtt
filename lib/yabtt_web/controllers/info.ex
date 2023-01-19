defmodule YaBTTWeb.Controllers.Info do
  @moduledoc """
  A controller (Plug) for the tracker statistics page.

  This controller is responsible to show the current state of the tracker.

  We query the state of the tracker by calling `YaBTT.Query.State.query/0`.
  Then we render the result to a HTML page using `EEx`. Finally, we send the
  response to the client (Browser).
  """

  @behaviour Plug

  import Plug.Conn

  @doc """
  Initializes the Plug.
  """
  @spec init(Plug.opts()) :: Plug.opts()
  def init(opts), do: opts

  @doc """
  Handles the request.

  Query, and render the result to a HTML page.

  Finally, send the response to the client.
  """
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
