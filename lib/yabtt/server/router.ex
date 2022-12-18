defmodule YaBTT.Server.Router do
  @moduledoc """
  Plug router for the Tracker application.

  This module is responsible for routing incoming requests to the appropriate
  controller action.

  The router is responsible for:
  - Logging all requests
  - Parsing the request body
  - Routing the request to the appropriate controller action
  - Returning a response to the client

  The router is not responsible for:
  - Performing any business logic

  The router is a Plug, which is a module that conforms to the Plug specification.
  A Plug is a module that implements a `call/2` function that takes a `Plug.Conn`
  struct and returns a `Plug.Conn` struct.
  """

  use Plug.Router
  import Plug.Conn

  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:urlencoded, :json], json_decoder: Jason)
  plug(:match)
  plug(:dispatch)

  get "/" do
    [host_url | _tail] = get_req_header(conn, "host")
    resp_msg = Jason.encode!(%{message: "#{conn.scheme}://#{host_url}/announce"})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, resp_msg)
  end

  forward("/announce", to: YaBTT.Server.Announce)

  match _ do
    resp_msg = Jason.encode!(%{message: "Not Found"})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, resp_msg)
  end
end
