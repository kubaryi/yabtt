defmodule YaBTT.Server.RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias YaBTT.Server.Router

  setup_all do
    {:ok, Router.init([])}
  end

  test "GET /", opts do
    conn =
      conn(:get, "/")
      # replace `put_req_header/3`
      |> set_req_header("host", "example.com")
      |> Router.call(opts)

    assert conn.state == :sent
  end

  test "Returns 404", opts do
    conn = conn(:get, "/missing", %{}) |> Router.call(opts)

    assert conn.state == :sent
  end

  # Set (put) the request header with the given key and value.
  #
  # Replace the `put_req_header/3` to avoid the following error:
  #
  #   ** (Plug.Conn.InvalidHeaderError) set the host header with %Plug.Conn{conn | host: "example.com"}
  #   code: |> put_req_header("host", "example.com")
  #   stacktrace:
  #     (plug 1.14.0) lib/plug/conn.ex:1890: Plug.Conn.validate_req_header!/2
  #     (plug 1.14.0) lib/plug/conn.ex:787: Plug.Conn.put_req_header/3
  #     test/yabtt/server/router_test.exs:14: (test)
  defp set_req_header(conn, key, value) do
    %Plug.Conn{conn | req_headers: [{key, value} | conn.req_headers]}
  end
end
