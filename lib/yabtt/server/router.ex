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
  plug(Plug.SSL)
  # The `info_hash` is a urlencoded 20-byte SHA1 hash, which is not a valid UTF-8 string.
  # See: https://wiki.theory.org/BitTorrentSpecification#Tracker_HTTP/HTTPS_Protocol
  plug(Plug.Parsers, parsers: [:urlencoded], validate_utf8: false)
  plug(:match)
  plug(:dispatch)

  get "/" do
    [host_url | _tail] = get_req_header(conn, "host")
    resp_msg = "#{conn.scheme}://#{host_url}/announce"

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, resp_msg)
  end

  forward("/announce", to: YaBTT.Server.Announce)
  forward("/scrape", to: YaBTT.Server.Scrape)

  match _ do
    not_found = "d14:failure reason9:not founde"

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(404, not_found)
  end
end
