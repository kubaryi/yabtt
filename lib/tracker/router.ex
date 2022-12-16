defmodule Tracker.Router do
  @moduledoc false

  use Plug.Router
  import Plug.Conn

  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:urlencoded, :json], json_decoder: Jason)
  plug(:match)
  plug(:dispatch)

  match _ do
    resp_msg = Jason.encode!(%{message: "Not Found"})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, resp_msg)
  end
end
